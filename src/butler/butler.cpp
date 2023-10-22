#include "butler.h"
#include "llama.h"
#include "common.h"

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
#include <atomic>
#include <mutex>

#if defined(_MSC_VER)
#pragma warning(disable: 4244 4267) // possible loss of data
#endif

static std::atomic_bool stop_generation(false);
static std::mutex continue_mutex;

static llama_model *model;
static llama_context *ctx;
struct llama_context_params ctx_params;

static std::vector<llama_token> last_n_tokens;
static std::vector<llama_token> embd;
static std::vector<llama_token> embd_inp;
static std::vector<llama_token> embd_cache;

static int n_remain;
static int n_past      = 0;
static int n_consumed  = 0;
static int n_pfx       = 0;
static int n_sfx       = 0;

gpt_params gpt_parameters;

int butler_start(struct butler_params *m_params) {
    llama_backend_init(false);

    gpt_parameters.seed             = (*m_params).seed              ? (*m_params).seed              : -1;
    gpt_parameters.n_ctx            = (*m_params).n_ctx             ? (*m_params).n_ctx             : 512;
    gpt_parameters.n_batch          = (*m_params).n_batch           ? (*m_params).n_batch           : 512;
    gpt_parameters.n_threads        = (*m_params).n_threads         ? (*m_params).n_threads         : get_num_physical_cores();
    gpt_parameters.n_threads_batch  = (*m_params).n_threads_batch   ? (*m_params).n_threads_batch   : -1;
    gpt_parameters.n_predict        = (*m_params).n_predict         ? (*m_params).n_predict         : 256;
    gpt_parameters.n_keep           = (*m_params).n_keep            ? (*m_params).n_keep            : 48;
    gpt_parameters.model            = (*m_params).model_path;
    gpt_parameters.prompt           = (*m_params).preprompt;
    gpt_parameters.input_prefix     = (*m_params).input_prefix;
    gpt_parameters.input_suffix     = (*m_params).input_suffix;

    gpt_parameters.antiprompt.push_back(gpt_parameters.input_prefix);
    //gpt_parameters.antiprompt.push_back((*m_params).input_suffix);

    gpt_parameters.memory_f16       = (*m_params).memory_f16        != 0;
    gpt_parameters.ignore_eos       = (*m_params).ignore_eos        != 0;
    gpt_parameters.instruct         = (*m_params).instruct          != 0;
    gpt_parameters.random_prompt    = (*m_params).random_prompt     != 0;

    n_remain = gpt_parameters.n_predict;

    std::tie(model, ctx) = llama_init_from_gpt_params(gpt_parameters);
    if (model == NULL) {
        fprintf(stderr, "%s: error: failed to load model '%s'\n", __func__, (*m_params).model_path);
        return 1;
    } else if (ctx == NULL) {
        fprintf(stderr, "%s: error: failed to create context with model '%s'\n", __func__,(*m_params).model_path);
        llama_free_model(model);
        return 1;
    }

    ctx_params = llama_context_params_from_gpt_params(gpt_parameters);

    const bool add_bos = llama_vocab_type(model) == LLAMA_VOCAB_TYPE_SPM;

    // tokenize the prompt
    embd_inp = ::llama_tokenize(model, gpt_parameters.prompt, add_bos, true);

    if ((int) embd_inp.size() > ctx_params.n_ctx - 4) {
        fprintf(stderr, "%s: error: prompt is too long (%d tokens, max %d)\n", __func__, (int) embd_inp.size(), ctx_params.n_ctx - 4);
        return 1;
    }

    // number of tokens to keep when resetting context
    if (gpt_parameters.n_keep < 0 || gpt_parameters.n_keep > (int) embd_inp.size() || gpt_parameters.instruct) {
        gpt_parameters.n_keep = (int)embd_inp.size();
    }

    last_n_tokens = std::vector<llama_token>(ctx_params.n_ctx);
    std::fill(last_n_tokens.begin(), last_n_tokens.end(), 0);

    return 0;
}

int butler_continue(const char *input, maid_output_cb *maid_output) {   
    std::string buffer(input);

    bool is_interacting = false;
    bool suffix_found = false;

    std::lock_guard<std::mutex> lock(continue_mutex);

    auto inp_pfx = ::llama_tokenize(ctx, gpt_parameters.input_prefix, false, true);
    auto inp_sfx = ::llama_tokenize(ctx, gpt_parameters.input_suffix, false, true);

    // Add tokens to embd only if the input buffer is non-empty
    // Entering a empty line lets the user pass control back
    if (buffer.length() > 1) {
        const auto inp_text = ::llama_tokenize(model, buffer,                    false, false);

        embd_inp.insert(embd_inp.end(), inp_pfx.begin(), inp_pfx.end());
        embd_inp.insert(embd_inp.end(), inp_text.begin(), inp_text.end());
        embd_inp.insert(embd_inp.end(), inp_sfx.begin(), inp_sfx.end());

        n_remain -= inp_text.size();
    }

    while (true) {
        if (stop_generation.load()) {
            stop_generation.store(false);  // reset for future use
            maid_output(return_code::STOP, "");
            return 0;  // or any other cleanup you want to do
        }

        if (n_past > 0) {
            is_interacting = false;
        }

        // In interactive mode, respect the maximum number of tokens and drop back to user input when reached.
        if (n_remain <= 0 && gpt_parameters.n_predict != -1) {
            n_remain = gpt_parameters.n_predict;
            is_interacting = true;
        }

        // predict
        if (embd.size() > 0) {
            // Note: n_ctx - 4 here is to match the logic for commandline prompt handling via
            // --prompt or --file which uses the same value.
            auto max_embd_size = ctx_params.n_ctx - 4;

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
            if (n_past + (int) embd.size() > ctx_params.n_ctx) {
                const int n_left = n_past - gpt_parameters.n_keep;

                // always keep the first token - BOS
                n_past = std::max(1, gpt_parameters.n_keep);

                // insert n_left/2 tokens at the start of embd from last_n_tokens
                embd.insert(embd.begin(), last_n_tokens.begin() + ctx_params.n_ctx - n_left/2 - embd.size(), last_n_tokens.end() - embd.size());
            }

            // evaluate tokens in batches
            // embd is typically prepared beforehand to fit within a batch, but not always
            for (int i = 0; i < (int) embd.size(); i += ctx_params.n_batch) {
                int n_eval = (int) embd.size() - i;
                if (n_eval > ctx_params.n_batch) {
                    n_eval = ctx_params.n_batch;
                }
                if (llama_decode(ctx, llama_batch_get_one(&embd[i], n_eval, n_past, 0))) {
                    fprintf(stderr, "%s : failed to eval\n", __func__);
                    return 1;
                }
                n_past += n_eval;
            }
        }

        embd.clear();

        if ((int) embd_inp.size() <= n_consumed && !is_interacting) {
            // out of user input, sample next token
            const float   alpha_presence  = 0.00f;
            const float   alpha_frequency = 0.00f;

            llama_token id = 0;

            {
                auto logits  = llama_get_logits(ctx);
                auto n_vocab = llama_n_vocab(model);

                std::vector<llama_token_data> candidates;
                candidates.reserve(n_vocab);
                for (llama_token token_id = 0; token_id < n_vocab; token_id++) {
                    candidates.emplace_back(llama_token_data{token_id, logits[token_id], 0.0f});
                }

                llama_token_data_array candidates_p = { candidates.data(), candidates.size(), false };

                // Apply penalties
                const int n_ctx = ctx_params.n_ctx;
                float nl_logit = logits[llama_token_nl(ctx)];
                auto last_n_repeat = std::min(std::min((int)last_n_tokens.size(), 64), n_ctx);
                llama_sample_repetition_penalty(ctx, &candidates_p,
                    last_n_tokens.data() + last_n_tokens.size() - last_n_repeat,
                    last_n_repeat, 1.0);
                llama_sample_frequency_and_presence_penalties(ctx, &candidates_p,
                    last_n_tokens.data() + last_n_tokens.size() - last_n_repeat,
                    last_n_repeat, alpha_frequency, alpha_presence);

                if (0.80f <= 0) {
                    // Greedy sampling
                    id = llama_sample_token_greedy(ctx, &candidates_p);
                } else {
                    // Temperature sampling
                    llama_sample_top_k(ctx, &candidates_p, 40, 1);
                    llama_sample_tail_free(ctx, &candidates_p, 1.00f, 1);
                    llama_sample_typical(ctx, &candidates_p, 1.00f, 1);
                    llama_sample_top_p(ctx, &candidates_p, 0.95f, 1);
                    llama_sample_temp(ctx, &candidates_p, 0.80f);
                    id = llama_sample_token(ctx, &candidates_p);
                }
                // printf("`%d`", candidates_p.size);

                last_n_tokens.erase(last_n_tokens.begin());
                last_n_tokens.push_back(id);
            }

            // replace end of text token with newline token when in interactive mode
            if (id == llama_token_eos(ctx)) {
                id = llama_token_nl(ctx);
                if (!gpt_parameters.antiprompt.empty()) {
                    // tokenize and inject first reverse prompt
                    const auto first_antiprompt = ::llama_tokenize(ctx, gpt_parameters.antiprompt.front(), false, true);
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
                if ((int) embd.size() >= ctx_params.n_batch) {
                    break;
                }
            }
        }

        auto embd_out = embd;

        // Remove input_prefix from output
        std::vector<int>::iterator it = embd_out.begin();
        while (it != embd_out.end()) {
            if (*it == inp_pfx[n_pfx]) {
                embd_cache.push_back(*it);
                it = embd_out.erase(it);
                n_pfx++;
        
                if (n_pfx == inp_pfx.size()) {
                    // Prefix found, reset
                    embd_cache.clear();
                    n_pfx = 0;
                    break;
                }
            } else if (n_pfx != 0) {
                // Started a sequence but it's broken now, reset
                embd_out.insert(embd_out.end(), embd_cache.begin(), embd_cache.end());
                embd_cache.clear();
                n_pfx = 0;
                ++it;
            } else {
                ++it;
            }
        }
        
        // Remove input_suffix from output
        it = embd_out.begin();
        while (it != embd_out.end()) {
            if (*it == inp_sfx[n_sfx]) {
                embd_cache.push_back(*it);
                it = embd_out.erase(it);
                n_sfx++;
        
                if (n_sfx == inp_sfx.size()) {
                    // Suffix found, reset
                    suffix_found = true;
                    embd_cache.clear();
                    n_sfx = 0;
                    break;
                }
            } else if (n_sfx != 0) {
                // Started a sequence but it's broken now, reset
                embd_out.insert(embd_out.end(), embd_cache.begin(), embd_cache.end());
                embd_cache.clear();
                n_sfx = 0;
                ++it;
            } else {
                ++it;
            }
        }

        if (suffix_found) {
            // display text
            for (auto id : embd_out) {
                const char * output = llama_token_to_piece(ctx, id).c_str();
                maid_output(return_code::CONTINUE, output);
                printf("%s\n", output);
            }
        }

        embd_out.clear();

        // if not currently processing queued inputs;
        if ((int) embd_inp.size() <= n_consumed) {
            // check for reverse prompt
            if (!gpt_parameters.antiprompt.empty()) {
                std::string last_output;
                for (auto id : last_n_tokens) {
                    last_output += llama_token_to_piece(ctx, id);
                }

                // Check if each of the reverse prompts appears at the end of the output.
                // If we're not running interactively, the reverse prompt might be tokenized with some following characters
                // so we'll compensate for that by widening the search window a bit.
                for (std::string & antiprompt : gpt_parameters.antiprompt) {
                    size_t extra_padding = gpt_parameters.interactive ? 0 : 2;
                    size_t search_start_pos = last_output.length() > static_cast<size_t>(antiprompt.length() + extra_padding)
                        ? last_output.length() - static_cast<size_t>(antiprompt.length() + extra_padding)
                        : 0;

                    if (last_output.find(antiprompt, search_start_pos) != std::string::npos) {
                        if (gpt_parameters.interactive) {
                            is_interacting = true;
                        }
                        maid_output(return_code::STOP, "");
                        return 0; 
                    }
                }
            }

            if (n_past > 0 && is_interacting) {
                return 0;
            }
        }
    }

    return 0;
}

void butler_stop(void) {
    stop_generation.store(true);
}

void butler_exit(void) {
    llama_print_timings(ctx);
    llama_free(ctx);
    llama_free_model(model);
}
