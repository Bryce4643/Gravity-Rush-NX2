// Switch 2 compat: <sched.h> additions, implemented in posix_compat.c.
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include_next <sched.h>

#ifdef __cplusplus
extern "C" {
#endif

#ifndef _POSIX_PRIORITY_SCHEDULING
int sched_get_priority_max(int policy);
int sched_get_priority_min(int policy);
#endif

#ifdef __cplusplus
}
#endif
