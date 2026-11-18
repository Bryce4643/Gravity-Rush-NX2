#!/bin/sh
# Configure the Switch 2 (kaiHEN / ounce-devkit) build of Vita3K for Gravity Rush.
#   ./switch2-configure.sh [build-dir] [extra cmake args...]   (default: build/switch2)
# Then build with:  ninja -C build/switch2 vita3k_nro
# The result is build/switch2/GravityRush.nro.
#
# Needs devkitPro (devkitA64 + switch portlibs) with the ounce-devkit installed
# (libounce, portlibs/switch2 with OunceVK and kaiHEN), cmake, ninja, perl, curl.
set -e

SRC="$(cd "$(dirname "$0")" && pwd)"
BUILD="${1:-$SRC/build/switch2}"
[ $# -gt 0 ] && shift

export DEVKITPRO="${DEVKITPRO:-/opt/devkitpro}"
export PATH="$DEVKITPRO/devkitA64/bin:$PATH"

if [ ! -f "$DEVKITPRO/libounce/cmake/Switch2.cmake" ]; then
	echo "error: $DEVKITPRO/libounce/cmake/Switch2.cmake not found - install the ounce-devkit" >&2
	exit 1
fi

# Submodule patches (the Switch 1 port's, plus the Switch 2 JIT changes in the
# dynarmic patch). Already-applied patches are skipped.
bash "$SRC/scripts/apply-switch-submodule-patches.sh"

# Static OpenSSL for aarch64-none-elf (built once into build/switch2-deps).
OPENSSL="${VITA3K_SWITCH2_OPENSSL:-$SRC/build/switch2-deps/openssl}"
if [ -z "$VITA3K_SWITCH2_OPENSSL" ]; then
	"$SRC/scripts/build-switch2-openssl.sh"
fi

# curl is fetched by CMake; set VITA3K_CURL_SRC to a checkout to build offline.
CURL_ARG=""
[ -n "$VITA3K_CURL_SRC" ] && CURL_ARG="-DFETCHCONTENT_SOURCE_DIR_CURL=$VITA3K_CURL_SRC"

cmake -S "$SRC" -B "$BUILD" -G Ninja \
	-DCMAKE_TOOLCHAIN_FILE="$DEVKITPRO/libounce/cmake/Switch2.cmake" \
	-DCMAKE_BUILD_TYPE=Release \
	-DSWITCH_OPENSSL_DIR="$OPENSSL" \
	-DOPENSSL_ROOT_DIR="$OPENSSL" -DOPENSSL_USE_STATIC_LIBS=TRUE \
	-DCMAKE_FIND_ROOT_PATH="$OPENSSL" \
	$CURL_ARG \
	"$@"
