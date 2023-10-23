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

static llama_model * model;
static llama_context * ctx;
static llama_context * ctx_guidance;

struct llama_context_params lparams;
struct llama_sampling_context * ctx_sampling;

static std::vector<llama_token> last_n_tokens;
static std::vector<llama_token> embd;
static std::vector<llama_token> embd_inp;

static int n_remain;
static int n_past               = 0;
static int n_consumed           = 0;
static int n_session_consumed   = 0;
static int n_past_guidance      = 0;
static int n_pfx                = 0;
static int n_sfx                = 0;

gpt_params params;

int butler_start(struct butler_params *bparams) {
    llama_backend_init(false);

    params.seed             = (*bparams).seed              ? (*bparams).seed              : -1;
    params.n_ctx            = (*bparams).n_ctx             ? (*bparams).n_ctx             : 512;
    params.n_batch          = (*bparams).n_batch           ? (*bparams).n_batch           : 512;
    params.n_threads        = (*bparams).n_threads         ? (*bparams).n_threads         : get_num_physical_cores();
    params.n_threads_batch  = (*bparams).n_threads_batch   ? (*bparams).n_threads_batch   : -1;
    params.n_predict        = (*bparams).n_predict         ? (*bparams).n_predict         : 256;
    params.n_keep           = (*bparams).n_keep            ? (*bparams).n_keep            : 48;
    params.model            = (*bparams).model_path;
    params.prompt           = (*bparams).preprompt;
    params.input_prefix     = (*bparams).input_prefix;
    params.input_suffix     = (*bparams).input_suffix;

    params.antiprompt.push_back((*bparams).input_prefix);
    params.antiprompt.push_back("\n\n\n\n");

    params.memory_f16       = (*bparams).memory_f16        != 0;
    params.ignore_eos       = (*bparams).ignore_eos        != 0;
    params.instruct         = (*bparams).instruct          != 0;
    params.random_prompt    = (*bparams).random_prompt     != 0;

    n_remain = params.n_predict;

    std::tie(model, ctx) = llama_init_from_gpt_params(params);
    if (model == NULL) {
        fprintf(stderr, "%s: error: failed to load model '%s'\n", __func__, (*bparams).model_path);
        return 1;
    } else if (ctx == NULL) {
        fprintf(stderr, "%s: error: failed to create context with model '%s'\n", __func__,(*bparams).model_path);
        llama_free_model(model);
        return 1;
    }

    lparams = llama_context_params_from_gpt_params(params);

    ctx_sampling = llama_sampling_init(params.sparams);

    if (params.sparams.cfg_scale > 1.f) {
        ctx_guidance = llama_new_context_with_model(model, lparams);
    }

    const bool add_bos = llama_vocab_type(model) == LLAMA_VOCAB_TYPE_SPM;

    // tokenize the prompt
    embd_inp = ::llama_tokenize(model, params.prompt, add_bos, true);

    if ((int) embd_inp.size() > lparams.n_ctx - 4) {
        fprintf(stderr, "%s: error: prompt is too long (%d tokens, max %d)\n", __func__, (int) embd_inp.size(), lparams.n_ctx - 4);
        return 1;
    }

    // number of tokens to keep when resetting context
    if (params.n_keep < 0 || params.n_keep > (int) embd_inp.size() || params.instruct) {
        params.n_keep = (int)embd_inp.size();
    }

    last_n_tokens = std::vector<llama_token>(lparams.n_ctx);
    std::fill(last_n_tokens.begin(), last_n_tokens.end(), 0);

    return 0;
}

int butler_continue(const char *input, maid_output_cb *maid_output) {   
    std::string buffer(input);

    bool is_interacting = false;
    bool suffix_found = false;

    std::vector<llama_token> embd_cache;

    std::lock_guard<std::mutex> lock(continue_mutex);
    stop_generation.store(false);

    auto inp_pfx = ::llama_tokenize(ctx, params.input_prefix, false, true);
    auto inp_sfx = ::llama_tokenize(ctx, params.input_suffix, false, true);

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

        // predict
        if (!embd.empty()) {
            // Note: lparams.n_ctx - 4 here is to match the logic for commandline prompt handling via
            // --prompt or --file which uses the same value.
            int max_embd_size = lparams.n_ctx - 4;

            // Ensure the input doesn't exceed the context size by truncating embd if necessary.
            if ((int) embd.size() > max_embd_size) {
                const int skipped_tokens = (int) embd.size() - max_embd_size;
                embd.resize(max_embd_size);
            }

            // infinite text generation via context swapping
            // if we run out of context:
            // - take the n_keep first tokens from the original prompt (via n_past)
            // - take half of the last (n_ctx - n_keep) tokens and recompute the logits in batches
            if (n_past + (int) embd.size() > lparams.n_ctx) {
                if (params.n_predict == -2) {
                    LOG_TEE("\n\n%s: context full and n_predict == -%d => stopping\n", __func__, params.n_predict);
                    break;
                }

                const int n_left    = n_past - params.n_keep - 1;
                const int n_discard = n_left/2;

                LOG("context full, swapping: n_past = %d, n_left = %d, lparams.n_ctx = %d, n_keep = %d, n_discard = %d\n",
                    n_past, n_left, lparams.n_ctx, params.n_keep, n_discard);

                llama_kv_cache_seq_rm   (ctx, 0, params.n_keep + 1            , params.n_keep + n_discard + 1);
                llama_kv_cache_seq_shift(ctx, 0, params.n_keep + 1 + n_discard, n_past, -n_discard);

                n_past -= n_discard;

                if (ctx_guidance) {
                    n_past_guidance -= n_discard;
                }

                LOG("after swap: n_past = %d, n_past_guidance = %d\n", n_past, n_past_guidance);

                LOG("embd: %s\n", LOG_TOKENS_TOSTR_PRETTY(ctx, embd).c_str());
            }

            for (int i = 0; i < (int) embd.size(); i += params.n_batch) {
                int n_eval = (int) embd.size() - i;
                if (n_eval > params.n_batch) {
                    n_eval = params.n_batch;
                }

                LOG("eval: %s\n", LOG_TOKENS_TOSTR_PRETTY(ctx, embd).c_str());

                if (llama_decode(ctx, llama_batch_get_one(&embd[i], n_eval, n_past, 0))) {
                    LOG_TEE("%s : failed to eval\n", __func__);
                    return 1;
                }

                n_past += n_eval;

                LOG("n_past = %d\n", n_past);
            }
        }

        embd.clear();

        if ((int) embd_inp.size() <= n_consumed && !is_interacting) {
            const llama_token id = llama_sampling_sample(ctx_sampling, ctx, NULL);

            llama_sampling_accept(ctx_sampling, ctx, id, true);

            embd.push_back(id);

            // decrement remaining sampling budget
            --n_remain;
        } else {
            // some user input remains from prompt or interaction, forward it to processing
            while ((int) embd_inp.size() > n_consumed) {
                embd.push_back(embd_inp[n_consumed]);

                // push the prompt in the sampling context in order to apply repetition penalties later
                // for the prompt, we don't apply grammar rules
                llama_sampling_accept(ctx_sampling, ctx, embd_inp[n_consumed], false);

                ++n_consumed;
                if ((int) embd.size() >= params.n_batch) {
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

        if (suffix_found) {
            // display text
            for (auto id : embd_out) {
                maid_output(return_code::CONTINUE, llama_token_to_piece(ctx, id).c_str());
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

        embd_out.clear();

        // if not currently processing queued inputs;
        if ((int) embd_inp.size() <= n_consumed) {
            // check for reverse prompt
            if (!params.antiprompt.empty()) {
                const int n_prev = 32;
                const std::string last_output = llama_sampling_prev_str(ctx_sampling, ctx, n_prev);

                // Check if each of the reverse prompts appears at the end of the output.
                // If we're not running interactively, the reverse prompt might be tokenized with some following characters
                // so we'll compensate for that by widening the search window a bit.
                for (std::string & antiprompt : params.antiprompt) {
                    size_t extra_padding = params.interactive ? 0 : 2;
                    size_t search_start_pos = last_output.length() > static_cast<size_t>(antiprompt.length() + extra_padding)
                        ? last_output.length() - static_cast<size_t>(antiprompt.length() + extra_padding)
                        : 0;

                    if (last_output.find(antiprompt, search_start_pos) != std::string::npos) {
                        if (params.interactive) {
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

            if (n_past > 0) {
                if (is_interacting) {
                    llama_sampling_reset(ctx_sampling);
                }
                is_interacting = false;
            }
        }

        // In interactive mode, respect the maximum number of tokens and drop back to user input when reached.
        // We skip this logic when n_predict == -1 (infinite) or -2 (stop at context size).
        if (params.interactive && n_remain <= 0 && params.n_predict >= 0) {
            n_remain = params.n_predict;
            is_interacting = true;
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
