// Switch 2 compat: <sys/un.h>. Horizon has no Unix-domain sockets; this only
// provides the address type so socket code that mentions it compiles.
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <sys/socket.h>

#ifndef AF_UNIX
#define AF_UNIX 1
#endif
#ifndef AF_LOCAL
#define AF_LOCAL AF_UNIX
#endif

struct sockaddr_un {
    sa_family_t sun_family;
    char sun_path[108];
};
