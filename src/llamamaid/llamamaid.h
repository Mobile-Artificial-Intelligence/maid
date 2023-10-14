#ifndef __LLAMAMAID_H
#define __LLAMAMAID_H

#ifdef __cplusplus
extern "C" {
#endif

#ifdef WIN32
   #define EXPORT __declspec(dllexport)
#else
   #define EXPORT __attribute__((visibility("default"))) __attribute__((used))
#endif

struct llamamaid_params {
   char *model_path;
   char *prompt;
   char *antiprompt;
};

typedef void maid_output_cb(const char *);

EXPORT int llamamaid_start(struct llamamaid_params *m_params, maid_output_cb *maid_output);

EXPORT int llamamaid_continue(const char *input, maid_output_cb *maid_output);

EXPORT void llamamaid_stop(void);

EXPORT void llamamaid_exit(void);

#ifdef __cplusplus
}
#endif
#endif
