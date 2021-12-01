#include <errno.h>
#include <stdint.h> // For fixed-width integral types
#include "lf_pico_threads_support.h"


/**
 * Create a new thread, starting with execution of lf_thread getting passed
 * arguments. The new handle is stored in thread.
 *
 * @return 0 on success, error number otherwise (see pthread_create()).
 */
int lf_thread_create(_lf_thread_t* thread, void *(*lf_thread) (void *), void* arguments) {
    return 0;
}

/**
 * Make calling thread wait for termination of the thread.  The
 * exit status of the thread is stored in thread_return, if thread_return
 * is not NULL.
 *
 * @return 0 on success, error number otherwise (see pthread_join()).
 */
int lf_thread_join(_lf_thread_t thread, void** thread_return) {
    return 0;
}

/**
 * Initialize a mutex.
 *
 * @return 0 on success, error number otherwise (see pthread_mutex_init()).
 */
int lf_mutex_init(_lf_mutex_t* mutex) {
    // Set up a recursive mutex
    return 0;
}

/**
 * Lock a mutex.
 *
 * @return 0 on success, error number otherwise (see pthread_mutex_lock()).
 */
int lf_mutex_lock(_lf_mutex_t* mutex) {
    return 0;
}

/** 
 * Unlock a mutex.
 *
 * @return 0 on success, error number otherwise (see pthread_mutex_unlock()).
 */
int lf_mutex_unlock(_lf_mutex_t* mutex) {
    return 0;
}

/** 
 * Initialize a conditional variable.
 *
 * @return 0 on success, error number otherwise (see pthread_cond_init()).
 */
int lf_cond_init(_lf_cond_t* cond) {
    return 0;
}

/** 
 * Wake up all threads waiting for condition variable cond.
 *
 * @return 0 on success, error number otherwise (see pthread_cond_broadcast()).
 */
int lf_cond_broadcast(_lf_cond_t* cond) {
    return 0;
}

/** 
 * Wake up one thread waiting for condition variable cond.
 *
 * @return 0 on success, error number otherwise (see pthread_cond_signal()).
 */
int lf_cond_signal(_lf_cond_t* cond) {
    return 0;
}

/** 
 * Wait for condition variable "cond" to be signaled or broadcast.
 * "mutex" is assumed to be locked before.
 *
 * @return 0 on success, error number otherwise (see pthread_cond_wait()).
 */
int lf_cond_wait(_lf_cond_t* cond, _lf_mutex_t* mutex) {
    return 0;
}

/** 
 * Block current thread on the condition variable until condition variable
 * pointed by "cond" is signaled or time pointed by "absolute_time_ns" in
 * nanoseconds is reached.
 * 
 * @return 0 on success, LF_TIMEOUT on timeout, and platform-specific error
 *  number otherwise (see pthread_cond_timedwait).
 */
int lf_cond_timedwait(_lf_cond_t* cond, _lf_mutex_t* mutex, int64_t absolute_time_ns) {
    return 0;
}