#ifndef LF_Pico_threads_SUPPORT_H
#define LF_Pico_threads_SUPPORT_H

#include <pthread.h>

typedef pthread_mutex_t _lf_mutex_t;
typedef pthread_cond_t _lf_cond_t;
typedef pthread_t _lf_thread_t;

#define _LF_TIMEOUT ETIMEDOUT

#endif // LF_Pico_threads_SUPPORT_H