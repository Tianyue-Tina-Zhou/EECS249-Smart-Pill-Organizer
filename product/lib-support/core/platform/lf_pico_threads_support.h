#ifndef LF_Pico_threads_SUPPORT_H
#define LF_Pico_threads_SUPPORT_H


//#include <mutex.h>

#include <stdio.h>
#include "pico/stdlib.h"
#include "pico/multicore.h"



typedef mutex_t     _lf_mutex_t;
typedef lock_core_t _lf_cond_t;
typedef void*       _lf_thread_t;

#define _LF_TIMEOUT ETIMEDOUT

#endif // LF_Pico_threads_SUPPORT_H