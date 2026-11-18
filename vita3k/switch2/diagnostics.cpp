// Switch 2 diagnostics.
//
// Under kaiHEN a CPU fault ends the process without running any exception
// handler, so whatever the logger still buffers is lost. A watchdog thread
// flushes the log every second and records a heartbeat with memory use, so the
// log shows how far the program got and whether it was running out of memory.
// abort() (which the allocator calls when it runs out of memory) is logged
// before the process ends.
// SPDX-License-Identifier: GPL-2.0-or-later

#include <util/log.h>

#include <spdlog/sinks/ringbuffer_sink.h>

#include <switch.h>
#include <switch2/memory/heap.h>

#include <atomic>
#include <chrono>
#include <cstdio>
#include <thread>
#include <string>
#include <memory>
#include <vector>

#include <fcntl.h>
#include <sys/stat.h>
#include <unistd.h>

extern "C" void __real_abort(void) __attribute__((noreturn));

namespace {

std::atomic<bool> g_running{ false };
std::thread g_watchdog;

void flush_log() {
    if (auto logger = spdlog::default_logger())
        logger->flush();
}

// The emulator keeps vita3k.log open, and the console cannot open a file that
// is already open, so FTP cannot read it while the game runs. A ring-buffer
// sink keeps the last lines in memory, and the watchdog writes them to
// vita3k.live.log (opened and closed each time) when there are new ones.
constexpr const char *LIVE_PATH = "sdmc:/switch/gravityrush/vita3k.live.log";
std::shared_ptr<spdlog::sinks::ringbuffer_sink_mt> g_live_sink;

void write_live_log() {
    if (!g_live_sink)
        return;
    static std::string last_line;
    const std::vector<std::string> lines = g_live_sink->last_formatted();
    if (lines.empty() || lines.back() == last_line)
        return;
    last_line = lines.back();
    FILE *out = std::fopen(LIVE_PATH, "w");
    if (!out)
        return;
    for (const std::string &line : lines)
        std::fwrite(line.data(), 1, line.size(), out);
    std::fclose(out);
}

void watchdog() {
    const auto start = std::chrono::steady_clock::now();
    while (g_running.load(std::memory_order_relaxed)) {
        std::this_thread::sleep_for(std::chrono::seconds(1));
        const auto elapsed = std::chrono::duration_cast<std::chrono::seconds>(std::chrono::steady_clock::now() - start).count();
        if (elapsed % 5 == 0) {
            LOG_INFO("[heartbeat] {} s, heap {} MiB free of {} MiB", elapsed,
                heapGetFreeSize() >> 20, heapGetTotalSize() >> 20);
        }
        flush_log();
        if (elapsed % 5 == 0)
            write_live_log();
    }
}

} // namespace

void switch2_diagnostics_start() {
    if (g_running.exchange(true))
        return;
    if (auto logger = spdlog::default_logger()) {
        g_live_sink = std::make_shared<spdlog::sinks::ringbuffer_sink_mt>(500);
        g_live_sink->set_pattern("[%H:%M:%S.%e] |%L| [%!]: %v");
        logger->sinks().push_back(g_live_sink);
    }
    LOG_INFO("[diagnostics] heap {} MiB free of {} MiB at startup", heapGetFreeSize() >> 20, heapGetTotalSize() >> 20);
    g_watchdog = std::thread(watchdog);
}

void switch2_diagnostics_stop() {
    if (!g_running.exchange(false))
        return;
    if (g_watchdog.joinable())
        g_watchdog.join();
    flush_log();
}

// Linked with --wrap=abort.
extern "C" void __wrap_abort(void) {
    static std::atomic<bool> reported{ false };
    if (!reported.exchange(true)) {
        LOG_CRITICAL("abort() called; heap {} MiB free of {} MiB", heapGetFreeSize() >> 20, heapGetTotalSize() >> 20);
        flush_log();
    }
    __real_abort();
}
