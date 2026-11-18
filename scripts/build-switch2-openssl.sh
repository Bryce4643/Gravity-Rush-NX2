#!/bin/sh
# Cross-builds a static OpenSSL (libcrypto + libssl) for Switch 2 into
#   build/switch2-deps/openssl   (headers in include/, libs in lib/)
# switch2-configure.sh runs it and points CMake at the result. Re-running is a no-op.
#
# Vita3K needs libcrypto for PKG/PFS decryption and SceSsl.
# Options: no-asm avoids the ARM capability probe (Linux getauxval / SIGILL
# probing); AES is then plain C, which only matters while installing.
# There is no OS entropy source, so RAND is left unseeded (not used by the
# decryption code).
set -e

VER=4.0.1
SHA256=2db3f3a0d6ea4b59e1f094ace2c8cd536dffb87cdc39084c5afa1e6f7f37dd09 # same pin as external/CMakeLists.txt
SRC="$(cd "$(dirname "$0")/.." && pwd)"
COMPAT="$SRC/vita3k/switch2/openssl-compat" # POSIX headers newlib lacks
DEPS="$SRC/build/switch2-deps"
PREFIX="$DEPS/openssl"

if [ -f "$PREFIX/lib/libcrypto.a" ] && [ -f "$PREFIX/lib/libssl.a" ]; then
	echo "OpenSSL already built in $PREFIX"
	exit 0
fi

export DEVKITPRO="${DEVKITPRO:-/opt/devkitpro}"
export PATH="$DEVKITPRO/devkitA64/bin:$PATH"
CPU="$(sed -n 's/^SWITCH2_CPU[[:space:]]*:=[[:space:]]*//p' "$DEVKITPRO/libounce/switch2_cpu.mk")"

mkdir -p "$DEPS/src"
TARBALL="$DEPS/src/openssl-$VER.tar.gz"
if [ ! -f "$TARBALL" ]; then
	curl -fL -o "$TARBALL.part" "https://github.com/openssl/openssl/releases/download/openssl-$VER/openssl-$VER.tar.gz"
	mv "$TARBALL.part" "$TARBALL"
fi
echo "$SHA256  $TARBALL" | sha256sum -c -

rm -rf "$DEPS/src/openssl-$VER"
tar xzf "$TARBALL" -C "$DEPS/src"
cd "$DEPS/src/openssl-$VER"

./Configure linux-aarch64 \
	--prefix="$PREFIX" --libdir=lib \
	--with-rand-seed=none \
	no-asm no-shared no-dso no-async no-tests no-afalgeng no-ui-console \
	no-apps no-docs no-module no-legacy \
	CC=aarch64-none-elf-gcc AR=aarch64-none-elf-gcc-ar RANLIB=aarch64-none-elf-gcc-ranlib \
	CFLAGS="$CPU -mtp=soft -fPIC -ftls-model=local-exec -O2 -ffunction-sections -fdata-sections -D__SWITCH__ -D__SWITCH2__ -D_GNU_SOURCE -DNO_SYSLOG -I$COMPAT -isystem $DEVKITPRO/libounce/include"

make -j3 build_libs
make install_dev

# Only the static libraries and headers are needed.
rm -rf "$DEPS/src/openssl-$VER"
echo "OpenSSL $VER installed in $PREFIX"
