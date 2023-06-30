#ifndef __LLAMASHERPA_H
#define __LLAMASHERPA_H

#ifdef WIN32
   #define EXPORT __declspec(dllexport)
#else
   #define EXPORT extern "C" __attribute__((visibility("default"))) __attribute__((used))
#endif

typedef void show_output_cb(const char *);

EXPORT int llamasherpa_start(const char *model_path, const char *_prompt, const char *_antiprompt, show_output_cb *show_output);

EXPORT int llamasherpa_continue(const char *input, show_output_cb *show_output);

EXPORT void llamasherpa_exit(void);

#endif
