// Switch 2: start-up checkpoints. A CPU fault under kaiHEN ends the process
// with no report, and the emulator log does not exist until start-up is well
// under way, so each stage appends one line to boot.log with an unbuffered
// write. The last line names the stage that did not finish.
// SPDX-License-Identifier: GPL-2.0-or-later

#include <fcntl.h>
#include <string.h>
#include <unistd.h>

static const char g_path[] = "sdmc:/switch/gravityrush/boot.log";

void switch2_boot_mark(const char *stage) {
    const int fd = open(g_path, O_WRONLY | O_CREAT | O_APPEND, 0644);
    if (fd < 0)
        return;
    write(fd, stage, strlen(stage));
    write(fd, "\n", 1);
    fsync(fd);
    close(fd);
}

// Runs before every other static constructor (C++ globals included), after
// libounce has mounted the SD card. Starts a fresh log for this run.
__attribute__((constructor(101))) static void switch2_boot_mark_first(void) {
    const int fd = open(g_path, O_WRONLY | O_CREAT | O_TRUNC, 0644);
    if (fd >= 0)
        close(fd);
    switch2_boot_mark("static init started");
}
