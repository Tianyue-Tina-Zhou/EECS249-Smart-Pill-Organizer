#include <time.h>
#include <errno.h>
#include "lf_pico_support.h"
/**
 * Initialize the LF clock. Must be called before using other clock-related APIs.
 */
void lf_initialize_clock() {
    stdio_init_all();
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
    *t = time_us_64()/1000;
    return 0;
}

/**
 * Pause execution for a number of nanoseconds.
 * 
 * @return 0 for success, or -1 for failure.
 */
int lf_nanosleep(instant_t requested_time) {

    sleep_us(requested_time/1000);

    return 0;
}