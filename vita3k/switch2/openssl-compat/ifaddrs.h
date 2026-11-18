// Switch 2 compat: <ifaddrs.h>. Network interface enumeration is not
// available; getifaddrs() reports no interfaces. Implemented in posix_compat.c.
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <sys/socket.h>

#ifdef __cplusplus
extern "C" {
#endif

struct ifaddrs {
    struct ifaddrs *ifa_next;
    char *ifa_name;
    unsigned int ifa_flags;
    struct sockaddr *ifa_addr;
    struct sockaddr *ifa_netmask;
    struct sockaddr *ifa_broadaddr;
    void *ifa_data;
};

#ifndef ifa_dstaddr
#define ifa_dstaddr ifa_broadaddr
#endif

int getifaddrs(struct ifaddrs **ifap);
void freeifaddrs(struct ifaddrs *ifa);

#ifdef __cplusplus
}
#endif
