#ifndef __BRIDGE_H
#define __BRIDGE_H

#ifdef __cplusplus
extern "C" {
#endif

#ifdef WIN32
   #define EXPORT __declspec(dllexport)
#else
   #define EXPORT __attribute__((visibility("default"))) __attribute__((used))
#endif

struct maid_params {
   unsigned char instruct;
   unsigned char interactive;
   unsigned char chatml;

   char *path;
   char *preprompt;
   char *input_prefix;                    // string to prefix user inputs with
   char *input_suffix;                    // string to suffix user inputs with

   unsigned int seed;                     // RNG seed
   int n_ctx;                             // context size
   int n_batch;                           // batch size for prompt processing (must be >=32 to use BLAS)
   int n_threads;                         // number of threads to use for processing
   int n_predict;                         // new tokens to predict
   int n_keep;                            // number of tokens to keep from initial prompt

   int top_k;                             // <= 0 to use vocab size
   float top_p;                           // 1.0 = disabled
   float min_p;                           // 1.0 = disabled
   float tfs_z;                           // 1.0 = disabled
   float typical_p;                       // 1.0 = disabled
   float temp;                            // 1.0 = disabled
   int penalty_last_n;                    // last n tokens to penalize (0 = disable penalty, -1 = context size)
   float penalty_repeat;                  // 1.0 = disabled
   float penalty_freq;                    // 0.0 = disabled
   float penalty_present;                 // 0.0 = disabled
   int mirostat;                          // 0 = disabled, 1 = mirostat, 2 = mirostat 2.0
   float mirostat_tau;                    // target entropy
   float mirostat_eta;                    // learning rate
   unsigned char penalize_nl;             // consider newlines as a repeatable token
};

enum return_code {
   STOP,
   CONTINUE,
};

typedef void maid_logger(const char *buffer);

typedef void maid_output_stream(unsigned char code, const char *buffer);

EXPORT int core_init(struct maid_params *mparams, maid_logger *log_output);

EXPORT int core_prompt(const char *input, maid_output_stream *maid_output);

EXPORT void core_stop(void);

EXPORT void core_cleanup(void);

#ifdef __cplusplus
}
#endif
#endif
