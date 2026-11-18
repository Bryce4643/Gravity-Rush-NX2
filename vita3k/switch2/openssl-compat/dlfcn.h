// Switch 2 compat: <dlfcn.h>. Horizon has no dynamic loader; everything is
// linked statically. dlopen() fails for every library except the Vulkan
// driver, which OunceVK links in statically (see posix_compat.c).
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#ifdef __cplusplus
extern "C" {
#endif

#define RTLD_LAZY 0x0001
#define RTLD_NOW 0x0002
#define RTLD_NOLOAD 0x0004
#define RTLD_LOCAL 0x0000
#define RTLD_GLOBAL 0x0100
#define RTLD_NODELETE 0x1000

#define RTLD_DEFAULT ((void *)0)
#define RTLD_NEXT ((void *)-1)

typedef struct {
    const char *dli_fname;
    void *dli_fbase;
    const char *dli_sname;
    void *dli_saddr;
} Dl_info;

void *dlopen(const char *filename, int flags);
void *dlsym(void *handle, const char *symbol);
int dlclose(void *handle);
char *dlerror(void);
int dladdr(const void *addr, Dl_info *info);

#ifdef __cplusplus
}
#endif
