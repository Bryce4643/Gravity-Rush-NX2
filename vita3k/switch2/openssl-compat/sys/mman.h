// Switch 2 compat: <sys/mman.h>. Horizon homebrew cannot reserve address
// space lazily or change page permissions on heap memory, so:
//  - mmap(MAP_ANONYMOUS) returns zeroed, page-aligned, fully committed heap
//    memory (Vita3K maps its 4 GiB guest space once at startup);
//  - mprotect() succeeds without changing anything (in page-table mode
//    Vita3K protects guest pages in software, see mem.cpp);
//  - madvise(MADV_DONTNEED) zero-fills, matching Linux anonymous memory.
// File mappings are not supported. Implemented in posix_compat.c.
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <stddef.h>
#include <sys/types.h>

#ifdef __cplusplus
extern "C" {
#endif

#define PROT_NONE 0x0
#define PROT_READ 0x1
#define PROT_WRITE 0x2
#define PROT_EXEC 0x4

#define MAP_SHARED 0x01
#define MAP_PRIVATE 0x02
#define MAP_FIXED 0x10
#define MAP_ANONYMOUS 0x20
#define MAP_ANON MAP_ANONYMOUS
#define MAP_NORESERVE 0x4000

#define MAP_FAILED ((void *)-1)

#define MADV_NORMAL 0
#define MADV_RANDOM 1
#define MADV_SEQUENTIAL 2
#define MADV_WILLNEED 3
#define MADV_DONTNEED 4

void *mmap(void *addr, size_t length, int prot, int flags, int fd, off_t offset);
int munmap(void *addr, size_t length);
int mprotect(void *addr, size_t length, int prot);
int madvise(void *addr, size_t length, int advice);

#ifdef __cplusplus
}
#endif
