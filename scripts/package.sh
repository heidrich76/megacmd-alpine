#!/bin/bash
set -e

export MEGA_VERSION="$1"
export MEGA_RELEASE="$2"

echo "MEGAcmd version: $MEGA_VERSION / release $MEGA_RELEASE"

# Create tar.gz package for release
export LICENSE_DIR=/tmp/mega_install/usr/share/licenses/megacmd/
mkdir -p "$LICENSE_DIR"
cp /opt/scripts/LICENSE "$LICENSE_DIR"
mkdir -p /packages
tar -czf /packages/megacmd-$1-r$2.tar.gz -C /tmp/mega_install .

# Create apk file for release
mkdir -p ~/megacmd && cd ~/megacmd
cp /opt/scripts/APKBUILD .
sed -i "s/^pkgver=.*/pkgver=$MEGA_VERSION/" ./APKBUILD
sed -i "s/^pkgrel=.*/pkgrel=$MEGA_RELEASE/" ./APKBUILD

# Correct line endings, if needed
sed -i 's/\r$//' /root/megacmd/APKBUILD

abuild-keygen -a -n -q

# Set success to true, because signature is not trusted and cannot be added
# to index
abuild -fFq || true

cp ~/packages/root/$(uname -m)/megacmd-$1-r$2.apk /packages

echo "Successfully created packages!"
