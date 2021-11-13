#include <time.h>
#include <errno.h>

/**
 * Initialize the LF clock. Must be called before using other clock-related APIs.
 */
void lf_initialize_clock() {
    return;
}

/**
 * Fetch the value of an internal (and platform-specific) physical clock and 
 * store it in `t`.
 * 
 * Ideally, the underlying platform clock should be monotonic. However, the
 * core lib tries to enforce monotonicity at higher level APIs (see tag.h).
 * 
 * @return 0 for success, or -1 for failure
 */
int lf_clock_gettime(instant_t* t) {
    return -1;
}

/**
 * Pause execution for a number of nanoseconds.
 * 
 * @return 0 for success, or -1 for failure.
 */
int lf_nanosleep(instant_t requested_time) {
    return -1;
}