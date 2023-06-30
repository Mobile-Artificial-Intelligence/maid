// Defines sigaction on msys:
#ifndef _GNU_SOURCE
#define _GNU_SOURCE
#endif

#include "llama.h"
#include "llamasherpa.h"

#include <cassert>
#include <cinttypes>
#include <cmath>
#include <cstdio>
#include <cstring>
#include <ctime>
#include <fstream>
#include <iostream>
#include <string>
#include <vector>
#include <unordered_set>
#include <thread>

#if defined(_MSC_VER)
#pragma warning(disable: 4244 4267) // possible loss of data
#endif

static bool is_interacting = false;
static const int initial_n_ctx = 512;
static int n_ctx;
static const int n_batch = 1024;
static const int n_predict = 256;
static int n_keep = 48;
static const float repeat_penalty = 1.0;
static const int32_t repeat_last_n = 64;
static const float presence_penalty = 0.00f;
static const float frequency_penalty = 0.00f;
static const int32_t top_k = 40;
static const float top_p = 0.95f;
static const float typical_p = 1.00f;
static const float temp = 0.80f;
static const float tfs_z = 1.00f;
static int mirostat          = 0;
static const float   mirostat_tau      = 5.00f;
static const float   mirostat_eta      = 0.10f;
static const bool penalize_nl = true;

int32_t get_num_physical_cores() {
#ifdef __linux__
    // enumerate the set of thread siblings, num entries is num cores
    std::unordered_set<std::string> siblings;
    for (uint32_t cpu=0; cpu < UINT32_MAX; ++cpu) {
        std::ifstream thread_siblings("/sys/devices/system/cpu"
            + std::to_string(cpu) + "/topology/thread_siblings");
        if (!thread_siblings.is_open()) {
            break; // no more cpus
        }
        std::string line;
        if (std::getline(thread_siblings, line)) {
            siblings.insert(line);
        }
    }
    if (siblings.size() > 0) {
        return static_cast<int32_t>(siblings.size());
    }
#elif defined(__APPLE__) && defined(__MACH__)
    int32_t num_physical_cores;
    size_t len = sizeof(num_physical_cores);
    int result = sysctlbyname("hw.perflevel0.physicalcpu", &num_physical_cores, &len, NULL, 0);
    if (result == 0) {
        return num_physical_cores;
    }
    result = sysctlbyname("hw.physicalcpu", &num_physical_cores, &len, NULL, 0);
    if (result == 0) {
        return num_physical_cores;
    }
#elif defined(_WIN32)
    //TODO: Implement
#endif
    unsigned int n_threads = std::thread::hardware_concurrency();
    return n_threads > 0 ? (n_threads <= 4 ? n_threads : n_threads / 2) : 4;
}
static int32_t n_threads = get_num_physical_cores();

// TODO: not great allocating this every time
std::vector<llama_token> llama_tokenize(struct llama_context * ctx, const std::string & text, bool add_bos) {
    // initialize to prompt numer of chars, since n_tokens <= n_prompt_chars
    std::vector<llama_token> res(text.size() + (int) add_bos);
    const int n = llama_tokenize(ctx, text.c_str(), res.data(), res.size(), add_bos);
    assert(n >= 0);
    res.resize(n);

    return res;
}

static llama_model *model;
static llama_context *ctx;
static std::vector<llama_token> llama_token_newline;
static std::string antiprompt;

// TODO: replace with ring-buffer
static std::vector<llama_token> last_n_tokens;
static bool is_antiprompt        = false;

static int n_past             = 0;
static int n_remain = n_predict;
static int n_consumed         = 0;

static std::vector<llama_token> embd;
static std::vector<llama_token> embd_inp;

int llamasherpa_start(const char *model_path, const char *_prompt, const char *_antiprompt, show_output_cb *show_output) {

    llama_init_backend(false);
    antiprompt = _antiprompt;

    // load the model and apply lora adapter, if any
    auto lparams = llama_context_default_params();

    lparams.n_ctx        = initial_n_ctx;
    lparams.n_batch      = n_batch;
    lparams.seed         = time(0);

    model  = llama_load_model_from_file(model_path, lparams);
    if (model == NULL) {
        fprintf(stderr, "%s: error: failed to load model '%s'\n", __func__, model_path);
        return 1;
    }

    ctx = llama_new_context_with_model(model, lparams);
    if (ctx == NULL) {
        fprintf(stderr, "%s: error: failed to create context with model '%s'\n", __func__,model_path);
        llama_free_model(model);
        return 1;
    }

    // print system information
    {
        fprintf(stderr, "\n");
        fprintf(stderr, "system_info: n_threads = %d / %d | %s\n",
                n_threads, std::thread::hardware_concurrency(), llama_print_system_info());
    }

    std::string prompt(_prompt);
    if (prompt.back() == '\n') {
        prompt.pop_back();
    }

    // Add a space in front of the first character to match OG llama tokenizer behavior
    prompt.insert(0, 1, ' ');

    // tokenize the prompt
    embd_inp = ::llama_tokenize(ctx, prompt, true);

    n_ctx = llama_n_ctx(ctx);

    if ((int) embd_inp.size() > n_ctx - 4) {
        fprintf(stderr, "%s: error: prompt is too long (%d tokens, max %d)\n", __func__, (int) embd_inp.size(), n_ctx - 4);
        return 1;
    }

    // number of tokens to keep when resetting context
    if (n_keep > (int) embd_inp.size()) {
        n_keep = (int)embd_inp.size();
    }

    // determine newline token
    llama_token_newline = ::llama_tokenize(ctx, "\n", false);

    fprintf(stderr, "%s: interactive mode on.\n", __func__);

    if (antiprompt.length() > 0) {
        fprintf(stderr, "Reverse prompt: '%s'\n", antiprompt.c_str());
    }

    fprintf(stderr, "sampling: repeat_last_n = %d, repeat_penalty = %f, presence_penalty = %f, frequency_penalty = %f, top_k = %d, tfs_z = %f, top_p = %f, typical_p = %f, temp = %f, mirostat = %d, mirostat_lr = %f, mirostat_ent = %f\n",
            repeat_last_n, repeat_penalty, presence_penalty, frequency_penalty, top_k, tfs_z, top_p, typical_p, temp, mirostat, mirostat_eta, mirostat_tau);
    fprintf(stderr, "generate: n_ctx = %d, n_batch = %d, n_predict = %d, n_keep = %d\n", n_ctx, n_batch, n_predict, n_keep);
    fprintf(stderr, "\n\n");

    last_n_tokens = std::vector<llama_token>(n_ctx);
    std::fill(last_n_tokens.begin(), last_n_tokens.end(), 0);

    // do one empty run to warm up the model
    {
        const std::vector<llama_token> tmp = { llama_token_bos(), };
        llama_eval(ctx, tmp.data(), tmp.size(), 0, n_threads);
        llama_reset_timings(ctx);
    }

    return 0;
}

int llamasherpa_continue(const char *input, show_output_cb *show_output) {
    std::string buffer(input);

    // Add tokens to embd only if the input buffer is non-empty
    // Entering a empty line lets the user pass control back
    if (buffer.length() > 1) {
        auto line_inp = ::llama_tokenize(ctx, buffer, false);
        embd_inp.insert(embd_inp.end(), line_inp.begin(), line_inp.end());

        n_remain -= line_inp.size();
    }

    if (n_past > 0) {
        is_interacting = false;
    }

    // In interactive mode, respect the maximum number of tokens and drop back to user input when reached.
    if (n_remain <= 0 && n_predict != -1) {
        n_remain = n_predict;
        is_interacting = true;
    }

    while (true) {
        // predict
        if (embd.size() > 0) {
            // Note: n_ctx - 4 here is to match the logic for commandline prompt handling via
            // --prompt or --file which uses the same value.
            auto max_embd_size = n_ctx - 4;
            // Ensure the input doesn't exceed the context size by truncating embd if necessary.
            if ((int)embd.size() > max_embd_size) {
                auto skipped_tokens = embd.size() - max_embd_size;
                printf("<<input too long: skipped %zu token%s>>", skipped_tokens, skipped_tokens != 1 ? "s" : "");
                fflush(stdout);
                embd.resize(max_embd_size);
            }

            // infinite text generation via context swapping
            // if we run out of context:
            // - take the n_keep first tokens from the original prompt (via n_past)
            // - take half of the last (n_ctx - n_keep) tokens and recompute the logits in batches
            if (n_past + (int) embd.size() > n_ctx) {
                const int n_left = n_past - n_keep;

                // always keep the first token - BOS
                n_past = std::max(1, n_keep);

                // insert n_left/2 tokens at the start of embd from last_n_tokens
                embd.insert(embd.begin(), last_n_tokens.begin() + n_ctx - n_left/2 - embd.size(), last_n_tokens.end() - embd.size());

                //printf("\n---\n");
                //printf("resetting: '");
                //for (int i = 0; i < (int) embd.size(); i++) {
                //    printf("%s", llama_token_to_str(ctx, embd[i]));
                //}
                //printf("'\n");
                //printf("\n---\n");
            }

            // evaluate tokens in batches
            // embd is typically prepared beforehand to fit within a batch, but not always
            for (int i = 0; i < (int) embd.size(); i += n_batch) {
                int n_eval = (int) embd.size() - i;
                if (n_eval > n_batch) {
                    n_eval = n_batch;
                }
                if (llama_eval(ctx, &embd[i], n_eval, n_past, n_threads)) {
                    fprintf(stderr, "%s : failed to eval\n", __func__);
                    return 1;
                }
                n_past += n_eval;
            }
        }

        embd.clear();

        if ((int) embd_inp.size() <= n_consumed && !is_interacting) {
            // out of user input, sample next token
            const float   alpha_presence  = presence_penalty;
            const float   alpha_frequency = frequency_penalty;

            llama_token id = 0;

            {
                auto logits  = llama_get_logits(ctx);
                auto n_vocab = llama_n_vocab(ctx);

                std::vector<llama_token_data> candidates;
                candidates.reserve(n_vocab);
                for (llama_token token_id = 0; token_id < n_vocab; token_id++) {
                    candidates.emplace_back(llama_token_data{token_id, logits[token_id], 0.0f});
                }

                llama_token_data_array candidates_p = { candidates.data(), candidates.size(), false };

                // Apply penalties
                float nl_logit = logits[llama_token_nl()];
                auto last_n_repeat = std::min(std::min((int)last_n_tokens.size(), repeat_last_n), n_ctx);
                llama_sample_repetition_penalty(ctx, &candidates_p,
                    last_n_tokens.data() + last_n_tokens.size() - last_n_repeat,
                    last_n_repeat, repeat_penalty);
                llama_sample_frequency_and_presence_penalties(ctx, &candidates_p,
                    last_n_tokens.data() + last_n_tokens.size() - last_n_repeat,
                    last_n_repeat, alpha_frequency, alpha_presence);
                if (!penalize_nl) {
                    logits[llama_token_nl()] = nl_logit;
                }

                if (temp <= 0) {
                    // Greedy sampling
                    id = llama_sample_token_greedy(ctx, &candidates_p);
                } else {
                    if (mirostat == 1) {
                        static float mirostat_mu = 2.0f * mirostat_tau;
                        const int mirostat_m = 100;
                        llama_sample_temperature(ctx, &candidates_p, temp);
                        id = llama_sample_token_mirostat(ctx, &candidates_p, mirostat_tau, mirostat_eta, mirostat_m, &mirostat_mu);
                    } else if (mirostat == 2) {
                        static float mirostat_mu = 2.0f * mirostat_tau;
                        llama_sample_temperature(ctx, &candidates_p, temp);
                        id = llama_sample_token_mirostat_v2(ctx, &candidates_p, mirostat_tau, mirostat_eta, &mirostat_mu);
                    } else {
                        // Temperature sampling
                        llama_sample_top_k(ctx, &candidates_p, top_k, 1);
                        llama_sample_tail_free(ctx, &candidates_p, tfs_z, 1);
                        llama_sample_typical(ctx, &candidates_p, typical_p, 1);
                        llama_sample_top_p(ctx, &candidates_p, top_p, 1);
                        llama_sample_temperature(ctx, &candidates_p, temp);
                        id = llama_sample_token(ctx, &candidates_p);
                    }
                }
                // printf("`%d`", candidates_p.size);

                last_n_tokens.erase(last_n_tokens.begin());
                last_n_tokens.push_back(id);
            }

            // replace end of text token with newline token when in interactive mode
            if (id == llama_token_eos()) {
                id = llama_token_newline.front();
                if (antiprompt.length() > 0) {
                    // tokenize and inject first reverse prompt
                    const auto first_antiprompt = ::llama_tokenize(ctx, antiprompt, false);
                    embd_inp.insert(embd_inp.end(), first_antiprompt.begin(), first_antiprompt.end());
                }
            }

            // add it to the context
            embd.push_back(id);

            // decrement remaining sampling budget
            --n_remain;
        } else {
            // some user input remains from prompt or interaction, forward it to processing
            while ((int) embd_inp.size() > n_consumed) {
                embd.push_back(embd_inp[n_consumed]);
                last_n_tokens.erase(last_n_tokens.begin());
                last_n_tokens.push_back(embd_inp[n_consumed]);
                ++n_consumed;
                if ((int) embd.size() >= n_batch) {
                    break;
                }
            }
        }

        // display text
        for (auto id : embd) {
            show_output(llama_token_to_str(ctx, id));
        }

        // if not currently processing queued inputs;
        if ((int) embd_inp.size() <= n_consumed) {

            // check for reverse prompt
            if (antiprompt.length() > 0) {
                std::string last_output;
                for (auto id : last_n_tokens) {
                    last_output += llama_token_to_str(ctx, id);
                }

                is_antiprompt = false;
                // Check if each of the reverse prompts appears at the end of the output.
                // If we're not running interactively, the reverse prompt might be tokenized with some following characters
                // so we'll compensate for that by widening the search window a bit.
                size_t extra_padding = 0;
                size_t search_start_pos = last_output.length() > static_cast<size_t>(antiprompt.length() + extra_padding)
                    ? last_output.length() - static_cast<size_t>(antiprompt.length() + extra_padding)
                    : 0;

                if (last_output.find(antiprompt.c_str(), search_start_pos) != std::string::npos) {
                    is_interacting = true;
                    is_antiprompt = true;
                    fflush(stdout);
                }
            }

            if (n_past > 0 && is_interacting) {
                return 0;
            }

            if (n_past > 0) {
                is_interacting = false;
            }
        }

        // In interactive mode, respect the maximum number of tokens and drop back to user input when reached.
        if (n_remain <= 0 && n_predict != -1) {
            n_remain = n_predict;
            is_interacting = true;
        }
    }

    return 0;
}

void llamasherpa_exit(void) {
    llama_print_timings(ctx);
    llama_free(ctx);
    llama_free_model(model);
}
