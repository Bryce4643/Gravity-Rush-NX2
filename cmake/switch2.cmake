# ---------------------------------------------------------------------------
# cmake/switch2.cmake
#
# Nintendo Switch 2 (kaiHEN homebrew, ounce-devkit) build wiring for the
# Gravity Rush build of Vita3K.
#
# Used in place of cmake/switch.cmake when the libounce toolchain is active
# (-DCMAKE_TOOLCHAIN_FILE=$DEVKITPRO/libounce/cmake/Switch2.cmake). That
# toolchain also sets NINTENDO_SWITCH, so SWITCH is set and every Switch code
# path is used; SWITCH2 marks the places where the Switch 2 differs:
#   * libounce instead of libnx (libnx-compatible API);
#   * OunceVK (NVK for the Switch 2 GPU) instead of the Mesa unified SDK,
#     Vulkan only (no OpenGL/Zink);
#   * kaiHEN JIT: written code is published to the executable mapping;
#   * Cortex-A78C, from the toolchain's own flags.
# ---------------------------------------------------------------------------

message(STATUS "================================================================")
message(STATUS " Vita3K: configuring for Nintendo Switch 2 (libounce / kaiHEN)")
message(STATUS "================================================================")

set(SWITCH2 1)

if(DEFINED ENV{DEVKITPRO})
	file(TO_CMAKE_PATH "$ENV{DEVKITPRO}" DEVKITPRO)
elseif(NOT DEVKITPRO)
	set(DEVKITPRO "/opt/devkitpro")
endif()

# Switch 1 portlibs that only need the C library (FFmpeg, zlib, ...) link
# against libounce unchanged. The Switch 2 portlibs hold OunceVK and kaiHEN.
set(SWITCH_PORTLIBS  "${DEVKITPRO}/portlibs/switch")
set(SWITCH2_PORTLIBS "${DEVKITPRO}/portlibs/switch2")
set(LIBNX            "${DEVKITPRO}/libounce")

include_directories(SYSTEM "${SWITCH2_PORTLIBS}/include" "${SWITCH_PORTLIBS}/include" "${LIBNX}/include")
link_directories("${SWITCH2_PORTLIBS}/lib" "${SWITCH_PORTLIBS}/lib" "${LIBNX}/lib")

# The toolchain's CMAKE_<LANG>_FLAGS carry the CPU flags and __SWITCH2__; they
# are not repeated here. __SWITCH__ comes from devkitPro's platform file.
add_compile_definitions(__SWITCH__ VITA3K_SWITCH VITA3K_SWITCH2 _GNU_SOURCE _DEFAULT_SOURCE)
add_compile_options(-pipe)

add_compile_definitions(VULKAN_HPP_ENABLE_DYNAMIC_LOADER_TOOL=0)
set(CMAKE_DISABLE_PRECOMPILE_HEADERS ON CACHE BOOL "" FORCE)
set(SPDLOG_NO_TZ_OFFSET ON CACHE BOOL "" FORCE)
set(USE_DISCORD_RICH_PRESENCE OFF CACHE BOOL "" FORCE)

# LTO roughly triples link memory; this machine builds with 14 GB. Enable it
# once the port works.
set(USE_LTO NEVER CACHE STRING "" FORCE)

# PGO profiles are for the Switch 1 build's GCC and code.
set(VITA3K_SWITCH_PGO "OFF" CACHE STRING "" FORCE)

# ---------------------------------------------------------------------------
# OpenSSL: a static aarch64-none-elf build (include/ and lib/ layout).
# ---------------------------------------------------------------------------
set(SWITCH_OPENSSL_DIR "" CACHE PATH "OpenSSL build for the Switch 2 (include/, lib/libcrypto.a, lib/libssl.a)")
if(NOT SWITCH_OPENSSL_DIR)
	message(FATAL_ERROR "SWITCH_OPENSSL_DIR is required (see switch2/configure.sh)")
endif()
foreach(_file include/openssl/ssl.h lib/libcrypto.a lib/libssl.a)
	if(NOT EXISTS "${SWITCH_OPENSSL_DIR}/${_file}")
		message(FATAL_ERROR "Invalid Switch 2 OpenSSL directory: missing ${SWITCH_OPENSSL_DIR}/${_file}")
	endif()
endforeach()
set(SWITCH_OPENSSL_LIBDIR "${SWITCH_OPENSSL_DIR}/lib")

# ---------------------------------------------------------------------------
# curl: built from source (there is no Switch curl portlib here). Only HTTP is
# used, and Gravity Rush does not need it, so it is kept minimal. Horizon has
# no socketpair/pipe wakeup.
# ---------------------------------------------------------------------------
set(CURL_DISABLE_SOCKETPAIR ON CACHE BOOL "" FORCE)
set(ENABLE_UNIX_SOCKETS OFF CACHE BOOL "" FORCE)
set(CURL_USE_LIBPSL OFF CACHE BOOL "" FORCE)
set(CURL_ZSTD OFF CACHE BOOL "" FORCE)
set(CURL_BROTLI OFF CACHE BOOL "" FORCE)
set(USE_LIBIDN2 OFF CACHE BOOL "" FORCE)
set(USE_NGHTTP2 OFF CACHE BOOL "" FORCE)
set(CURL_USE_LIBSSH2 OFF CACHE BOOL "" FORCE)

# SDL's configure checks: sysconf exists (switch2 compat); sysctlbyname must
# not be used (on libounce it goes to the BSD socket service and hung forever
# in SDL_GetNumLogicalCPUCores).
set(HAVE_SYSCONF 1 CACHE INTERNAL "")
set(HAVE_SYSCTLBYNAME "" CACHE INTERNAL "")

# ---------------------------------------------------------------------------
# OunceVK: the Vulkan driver, linked statically (libvulkan.a is a linker
# script for libouncevk.a). Vita3K calls Vulkan only through
# vkGetInstanceProcAddr, so there is no loader.
# ---------------------------------------------------------------------------
add_library(ouncevk STATIC IMPORTED GLOBAL)
set_target_properties(ouncevk PROPERTIES
	IMPORTED_LOCATION "${SWITCH2_PORTLIBS}/lib/libouncevk.a"
	INTERFACE_LINK_LIBRARIES "stdc++;m")
set(SWITCH_VULKAN_LINK_LIBS ouncevk CACHE INTERNAL "" FORCE)
set(SWITCH_VULKAN_INCLUDE_DIR "" CACHE INTERNAL "" FORCE)
set(SWITCH_VULKAN_LINK_DEPENDS "${SWITCH2_PORTLIBS}/lib/libouncevk.a" CACHE INTERNAL "" FORCE)

# Switch 2 frontend sources (crash diagnostics, kaiHEN helpers).
set(SWITCH2_DIR "${CMAKE_SOURCE_DIR}/vita3k/switch2")
