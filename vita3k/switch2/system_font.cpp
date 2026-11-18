// Switch 2: a font for the overlay (trophy notifications and dialogs).
// The Vita's own fonts come from a separate firmware package that most
// installs lack, and without them the overlay draws no text. The console's
// shared system font is always present: write it out once as a TTF file and
// offer its folder to the overlay's font lookup.
// SPDX-License-Identifier: GPL-2.0-or-later

#include <util/log.h>

#include <switch.h>

#include <cstdio>
#include <string>
#include <sys/stat.h>
#include <vector>

std::vector<std::string> switch2_system_font_dirs() {
    static const std::string dir = "sdmc:/switch/gravityrush/cache/fonts/";
    static const std::string path = dir + "SwitchStandard.ttf";
    static bool ready = [] {
        struct stat st {};
        if (stat(path.c_str(), &st) == 0 && st.st_size > 0)
            return true;
        mkdir("sdmc:/switch/gravityrush/cache", 0777);
        mkdir(dir.c_str(), 0777);
        Result rc = plInitialize(PlServiceType_User);
        if (R_FAILED(rc)) {
            LOG_WARN("System font unavailable: plInitialize failed (0x{:X})", rc);
            return false;
        }
        PlFontData font{};
        rc = plGetSharedFontByType(&font, PlSharedFontType_Standard);
        bool written = false;
        if (R_SUCCEEDED(rc) && font.address && font.size) {
            if (FILE *f = std::fopen(path.c_str(), "wb")) {
                written = std::fwrite(font.address, 1, font.size, f) == font.size;
                std::fclose(f);
            }
        } else {
            LOG_WARN("System font unavailable: plGetSharedFontByType failed (0x{:X})", rc);
        }
        plExit();
        if (written)
            LOG_INFO("Overlay font: wrote the system font to {}", path);
        else
            std::remove(path.c_str());
        return written;
    }();
    if (!ready)
        return {};
    return { dir };
}
