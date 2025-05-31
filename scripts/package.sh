#!/bin/bash
set -e

echo "MEGAcmd version: $1 / release $2"

# Create tar.gz package for release
mkdir -p /packages
tar -czf /packages/megacmd-$1-r$2.tar.gz -C /tmp/mega_install .

# Create apk file for release
mkdir -p ~/megacmd && cd ~/megacmd
cp /opt/scripts/APKBUILD .
sed -i "s/^pkgver=.*/pkgver=$1/" ./APKBUILD
sed -i "s/^pkgrel=.*/pkgrel=$2/" ./APKBUILD

abuild-keygen -a -n -q

# Set success to true, because signature is not trusted and cannot be added
# to index
abuild -fFq || true

cp ~/packages/root/$(uname -m)/megacmd-$1-r$2.apk /packages

echo "Successfully created packages!"
