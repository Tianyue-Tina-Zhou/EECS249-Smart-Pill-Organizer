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
    return pthread_create((pthread_t*)thread, NULL, lf_thread, arguments);
}

/**
 * Make calling thread wait for termination of the thread.  The
 * exit status of the thread is stored in thread_return, if thread_return
 * is not NULL.
 *
 * @return 0 on success, error number otherwise (see pthread_join()).
 */
int lf_thread_join(_lf_thread_t thread, void** thread_return) {
    return pthread_join((pthread_t)thread, thread_return);
}

/**
 * Initialize a mutex.
 *
 * @return 0 on success, error number otherwise (see pthread_mutex_init()).
 */
int lf_mutex_init(_lf_mutex_t* mutex) {
    // Set up a recursive mutex
    pthread_mutexattr_t attr;
    pthread_mutexattr_init(&attr);
    pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_RECURSIVE);
    return pthread_mutex_init((pthread_mutex_t*)mutex, &attr);
}

/**
 * Lock a mutex.
 *
 * @return 0 on success, error number otherwise (see pthread_mutex_lock()).
 */
int lf_mutex_lock(_lf_mutex_t* mutex) {
    return pthread_mutex_lock((pthread_mutex_t*)mutex);
}

/** 
 * Unlock a mutex.
 *
 * @return 0 on success, error number otherwise (see pthread_mutex_unlock()).
 */
int lf_mutex_unlock(_lf_mutex_t* mutex) {
    return pthread_mutex_unlock((pthread_mutex_t*)mutex);
}

/** 
 * Initialize a conditional variable.
 *
 * @return 0 on success, error number otherwise (see pthread_cond_init()).
 */
int lf_cond_init(_lf_cond_t* cond) {
    pthread_condattr_t cond_attr;
    pthread_condattr_init(&cond_attr);
    // Limit the scope of the condition variable to this process (default)
    pthread_condattr_setpshared(&cond_attr, PTHREAD_PROCESS_PRIVATE);
    return pthread_cond_init(cond, &cond_attr);
}

/** 
 * Wake up all threads waiting for condition variable cond.
 *
 * @return 0 on success, error number otherwise (see pthread_cond_broadcast()).
 */
int lf_cond_broadcast(_lf_cond_t* cond) {
    return pthread_cond_broadcast((pthread_cond_t*)cond);
}

/** 
 * Wake up one thread waiting for condition variable cond.
 *
 * @return 0 on success, error number otherwise (see pthread_cond_signal()).
 */
int lf_cond_signal(_lf_cond_t* cond) {
    return pthread_cond_signal((pthread_cond_t*)cond);
}

/** 
 * Wait for condition variable "cond" to be signaled or broadcast.
 * "mutex" is assumed to be locked before.
 *
 * @return 0 on success, error number otherwise (see pthread_cond_wait()).
 */
int lf_cond_wait(_lf_cond_t* cond, _lf_mutex_t* mutex) {
    return pthread_cond_wait((pthread_cond_t*)cond, (pthread_mutex_t*)mutex);
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
    // Convert the absolute time to a timespec.
    // timespec is seconds and nanoseconds.
    struct timespec timespec_absolute_time
            = {(time_t)absolute_time_ns / 1000000000LL, (long)absolute_time_ns % 1000000000LL};
    int return_value = 0;
    return_value = pthread_cond_timedwait(
        (pthread_cond_t*)cond,
        (pthread_mutex_t*)mutex,
        &timespec_absolute_time
    );
    switch (return_value) {
        case ETIMEDOUT:
            return_value = _LF_TIMEOUT;
            break;
        
        default:
            break;
    }
    return return_value;
}