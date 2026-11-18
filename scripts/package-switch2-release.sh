#!/bin/sh
# Packages the Switch 2 Gravity Rush build for a release:
#   dist/GravityRush-Switch2-<version>.zip
# containing the SD card layout (switch/gravityrush/GravityRush.nro), the
# README and the licenses of everything linked into the NRO.
#   scripts/package-switch2-release.sh [build-dir]   (default: build/switch2)
# Never packages game data, PS Vita firmware or Lossless Scaling files.
set -e

SRC="$(cd "$(dirname "$0")/.." && pwd)"
BUILD="${1:-$SRC/build/switch2}"
NRO="$BUILD/GravityRush.nro"
DEVKITPRO="${DEVKITPRO:-/opt/devkitpro}"

[ -f "$NRO" ] || { echo "error: $NRO not found - build it first (ninja -C $BUILD vita3k_nro)" >&2; exit 1; }

VERSION="$(git -C "$SRC" describe --tags --always --dirty 2>/dev/null || echo dev)"
NAME="GravityRush-Switch2-$VERSION"
STAGE="$SRC/dist/$NAME"
rm -rf "$STAGE" "$SRC/dist/$NAME.zip"
mkdir -p "$STAGE/switch/gravityrush/lsfg" "$STAGE/licenses/third-party"

# The SD card layout.
cp "$NRO" "$STAGE/switch/gravityrush/GravityRush.nro"
cat > "$STAGE/switch/gravityrush/lsfg/PUT_Lossless.dll_HERE.txt" <<'EOF'
Optional frame generation: copy Lossless.dll from YOUR OWN copy of Lossless Scaling
(Steam, "lsfg-vk" beta branch) into this folder, then turn on
"Frame generation (next launch)" in the quick menu's Settings (L + R + +).
See README.md.
EOF
cp "$SRC/README.md" "$STAGE/README.md"

# Licenses: Vita3K (GPL v2) ...
cp "$SRC/COPYING.txt" "$STAGE/licenses/Vita3K-GPL-2.0.txt"
# ... the ounce-devkit and kaiHEN (libounce, libnx, mimalloc, kaiHEN, OunceVK/Mesa, zlib) ...
for f in "$DEVKITPRO"/libounce/licenses/* "$DEVKITPRO"/portlibs/switch2/share/licenses/*/*; do
	[ -f "$f" ] || continue
	owner="$(basename "$(dirname "$f")")"
	case "$owner" in licenses) cp "$f" "$STAGE/licenses/third-party/$(basename "$f")" ;;
	*) cp "$f" "$STAGE/licenses/third-party/$owner-$(basename "$f")" ;; esac
done
# ... OpenSSL ...
OSSL_TAR="$(ls "$SRC"/build/switch2-deps/src/openssl-*.tar.gz 2>/dev/null | head -1)"
if [ -n "$OSSL_TAR" ]; then
	tar xzf "$OSSL_TAR" -O --wildcards '*/LICENSE.txt' > "$STAGE/licenses/third-party/OpenSSL-LICENSE.txt"
fi
# ... and the bundled libraries linked into the NRO.
for lib in boost capstone concurrentqueue ddspp dirent dynarmic fmt glslang LibAtrac9 libfat16 \
		lsfg-vk miniz printf pugixml sdl spdlog SPIRV-Cross stb substitute VulkanMemoryAllocator-Hpp \
		xxHash yaml-cpp; do
	f="$(ls "$SRC/external/$lib" 2>/dev/null | grep -i -m1 '^\(license\|copying\)' || true)"
	[ -n "$f" ] && cp "$SRC/external/$lib/$f" "$STAGE/licenses/third-party/$lib-$f"
done
cat > "$STAGE/licenses/README.txt" <<'EOF'
GravityRush.nro is Vita3K (GNU GPL v2, see Vita3K-GPL-2.0.txt) built for the
Nintendo Switch 2 with the ounce-devkit. Its source code, including all Switch 2
changes, is in the project's GitHub repository.

third-party/ holds the licenses of the libraries linked into the NRO: the
ounce-devkit (libounce, libnx, mimalloc), kaiHEN, OunceVK (Mesa), OpenSSL, SDL,
dynarmic and the others in Vita3K's external/ folder. FFmpeg comes from
devkitPro's switch-ffmpeg portlib (LGPL/GPL; source at https://ffmpeg.org).

Not included: games, PS Vita firmware, fonts, or Lossless Scaling (Lossless.dll).
EOF

# Safety: nothing that must not be redistributed.
if find "$STAGE" -iname 'Lossless.dll' -o -iname '*.pup' -o -iname 'eboot.bin' -o -iname '*.psarc' | grep -q .; then
	echo "error: the package contains game, firmware or Lossless Scaling files" >&2
	exit 1
fi

(cd "$SRC/dist" && zip -qr "$NAME.zip" "$NAME")
echo "$SRC/dist/$NAME.zip"
(cd "$SRC/dist" && unzip -l "$NAME.zip" | tail -n +4 | head -n -2 | awk '{print $4}' | grep -v '/$')
