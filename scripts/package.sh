#!/bin/bash
set -e

# Read environment variables for packaging
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/build.env"
echo "MEGAcmd version: $MEGA_VERSION"
export MEGA_RELEASE=0

# Create tar.gz package for release
export LICENSE_DIR=/tmp/mega_install/usr/share/licenses/megacmd/
mkdir -p "$LICENSE_DIR"
cp /scripts/LICENSE "$LICENSE_DIR"
mkdir -p /packages
tar -czf /packages/megacmd-$MEGA_VERSION-r$MEGA_RELEASE.tar.gz -C /tmp/mega_install .

# Create apk file for release
mkdir -p ~/megacmd && cd ~/megacmd
cp /scripts/APKBUILD .
sed -i "s/^pkgver=.*/pkgver=$MEGA_VERSION/" ./APKBUILD
sed -i "s/^pkgrel=.*/pkgrel=$MEGA_RELEASE/" ./APKBUILD

abuild-keygen -a -n -q

# Set success to true, because signature is not trusted and cannot be added
# to index
abuild -fFq || true

cp ~/packages/root/$(uname -m)/megacmd-$MEGA_VERSION-r$MEGA_RELEASE.apk /packages

echo "Successfully created packages!"
