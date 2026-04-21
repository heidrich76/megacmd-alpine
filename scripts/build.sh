#!/bin/bash
set -e

# Read environment variables for build
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/build.env"
echo "MEGAcmd tag: $MEGA_TAG"
echo "VCPKG tag: $VCPKG_TAG"

# Add recent version of ninja
export PATH="/usr/lib/ninja-build/bin:$PATH"

# Avoid deprecation warnings
export CXXFLAGS="-Wno-deprecated-declarations"

# Clone VCPKG source code und bootstrap app
git clone --branch "$VCPKG_TAG" --single-branch https://github.com/microsoft/vcpkg.git /vcpkg
cd /vcpkg && ./bootstrap-vcpkg.sh

# Clone MEGAcmd source code und update dependencies
git clone --branch "$MEGA_TAG" --single-branch --depth 1 https://github.com/meganz/MEGAcmd.git /MEGAcmd
cd /MEGAcmd && git submodule update --init --recursive

# Patch freeimage port and copy to MEGAcmd SDK overlay ports
# diff -u PluginPSD.cpp.orig PluginPSD.cpp > /scripts/vcpkg-freeimage-PluginPSD.patch
# diff -u portfile.cmake.orig portfile.cmake > /scripts/vcpkg-freeimage-portfile.patch
cp /scripts/vcpkg-freeimage-PluginPSD.patch /vcpkg/ports/freeimage
cd /vcpkg/ports/freeimage && cp portfile.cmake portfile.cmake.orig
patch portfile.cmake </scripts/vcpkg-freeimage-portfile.patch
cp -r /vcpkg/ports/freeimage /MEGAcmd/sdk/cmake/vcpkg_overlay_ports/

# Patch source code net.cpp
# diff -u net.cpp.orig net.cpp > /scripts/vcpkg-mega-net.patch
cd /MEGAcmd/sdk/src/posix/ && cp net.cpp net.cpp.orig
patch net.cpp </scripts/vcpkg-mega-net.patch

# Patch source code MegaUpdater.cpp
# diff -u MegaUpdater.cpp.orig MegaUpdater.cpp > /scripts/vcpkg-mega-updater.patch
cd /MEGAcmd/src/updater/ && cp MegaUpdater.cpp MegaUpdater.cpp.orig
patch MegaUpdater.cpp </scripts/vcpkg-mega-updater.patch

# Determine triplet to use
cd /MEGAcmd
case "$(uname -m)" in
x86_64) triplet="-DVCPKG_TARGET_TRIPLET=x64-linux-mega" ;;
aarch64) triplet="-DVCPKG_TARGET_TRIPLET=arm64-linux-mega" ;;
*) triplet="" ;;
esac

# Build MEGAcmd dependencies
cmake -B /tmp/build/ -DCMAKE_BUILD_TYPE=Release $triplet

# Build MEGAcmd code
cmake --build /tmp/build/

# Install MEGAcmd
cmake --install /tmp/build/ --prefix /tmp/mega_install
