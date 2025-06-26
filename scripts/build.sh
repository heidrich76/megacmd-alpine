#!/bin/bash
set -e

echo "MEGAcmd tag: $1"

# Add recent version of ninja
export PATH="/usr/lib/ninja-build/bin:$PATH"

# Avoid deprecation warnings
export CXXFLAGS="-Wno-deprecated-declarations"

# Clone VCPKG source code und bootstrap app
git clone --branch 2025.06.13 --single-branch https://github.com/microsoft/vcpkg.git /vcpkg
cd /vcpkg && ./bootstrap-vcpkg.sh

# Clone MEGAcmd source code und update dependencies
git clone --branch "$1" --single-branch --depth 1 https://github.com/meganz/MEGAcmd.git /MEGAcmd
cd /MEGAcmd && git submodule update --init --recursive

# Patch freeimage port and copy to MEGAcmd SDK overlay ports
# diff -u PluginPSD.cpp.orig PluginPSD.cpp > /opt/scripts/vcpkg-freeimage-PluginPSD.patch
# diff -u portfile.cmake.orig portfile.cmake > /opt/scripts/vcpkg-freeimage-portfile.patch
cp /opt/scripts/vcpkg-freeimage-PluginPSD.patch /vcpkg/ports/freeimage
cd /vcpkg/ports/freeimage && cp portfile.cmake portfile.cmake.orig
patch portfile.cmake </opt/scripts/vcpkg-freeimage-portfile.patch
cp -r /vcpkg/ports/freeimage /MEGAcmd/sdk/cmake/vcpkg_overlay_ports/

# Patch pdfium port
# diff -u CMakeLists.txt.orig CMakeLists.txt > /opt/scripts/vcpkg-pdfium-port.patch
cd /MEGAcmd/sdk/cmake/vcpkg_overlay_ports/pdfium && cp CMakeLists.txt CMakeLists.txt.orig
patch CMakeLists.txt </opt/scripts/vcpkg-pdfium-port.patch

# Patch source code net.cpp
# diff -u net.cpp.orig net.cpp > /opt/scripts/vcpkg-mega-net.patch
cd /MEGAcmd/sdk/src/posix/ && cp net.cpp net.cpp.orig
patch net.cpp </opt/scripts/vcpkg-mega-net.patch

# Patch source code MegaUpdater.cpp
# diff -u MegaUpdater.cpp.orig MegaUpdater.cpp > /opt/scripts/vcpkg-mega-updater.patch
cd /MEGAcmd/src/updater/ && cp MegaUpdater.cpp MegaUpdater.cpp.orig
patch MegaUpdater.cpp </opt/scripts/vcpkg-mega-updater.patch

# Tinyxml2 port from VCPKG must be available in MEGAcmd SDK overlay ports
cp -r /vcpkg/ports/tinyxml2 /MEGAcmd/sdk/cmake/vcpkg_overlay_ports/

# Copy new cmake file for arm64 Linux
cp /opt/scripts/arm64-linux.cmake /MEGAcmd/sdk/cmake/vcpkg_overlay_triplets/

# Determine triplet to use
cd /MEGAcmd
case "$(uname -m)" in
x86_64) triplet="-DVCPKG_TARGET_TRIPLET=x64-linux-mega" ;;
aarch64) triplet="-DVCPKG_TARGET_TRIPLET=arm64-linux" ;;
*) triplet="" ;;
esac

# Build MEGAcmd dependencies
cmake -B /tmp/build/ -DCMAKE_BUILD_TYPE=Release $triplet

# Build MEGAcmd code
cmake --build /tmp/build/

# Install MEGAcmd
cmake --install /tmp/build/ --prefix /tmp/mega_install
