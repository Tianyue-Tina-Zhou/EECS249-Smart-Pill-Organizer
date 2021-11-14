#ifndef LF_Pico_threads_SUPPORT_H
#define LF_Pico_threads_SUPPORT_H

#include <threads.h>

typedef mtx_t _lf_mutex_t;
typedef cnd_t _lf_cond_t;
typedef thrd_t _lf_thread_t;

#define _LF_TIMEOUT ETIMEDOUT

#endif // LF_Pico_threads_SUPPORT_H