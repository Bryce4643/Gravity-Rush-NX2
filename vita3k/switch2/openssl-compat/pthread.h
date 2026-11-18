// Switch 2 compat: <pthread.h> additions. newlib declares the dynamic
// scheduling functions only under _POSIX_THREAD_PRIORITY_SCHEDULING, which
// libounce does not set, and libounce does not implement them. They are
// provided by posix_compat.c.
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include_next <pthread.h>

#ifdef __cplusplus
extern "C" {
#endif

#ifndef _POSIX_THREAD_PRIORITY_SCHEDULING
int pthread_getschedparam(pthread_t thread, int *policy, struct sched_param *param);
int pthread_setschedparam(pthread_t thread, int policy, const struct sched_param *param);
#endif

#ifdef __cplusplus
}
#endif
