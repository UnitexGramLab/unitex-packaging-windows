#!/bin/bash
# martinec
set -eo pipefail

NSIS_VERSION="3.0a2"
NSIS_NAME="nsis"
NSIS_DIST="$NSIS_NAME-$NSIS_VERSION"
NSIS_SOURCE="$NSIS_DIST-src"
NSIS_MIRROR="http://iweb.dl.sourceforge.net/project/$NSIS_NAME"
NSIS_RELEASE="$NSIS_MIRROR/NSIS%203%20Pre-release/$NSIS_VERSION"

curl -s "$NSIS_RELEASE/$NSIS_DIST.zip" -o "$NSIS_DIST.zip"
unzip "$NSIS_DIST"
mv "$NSIS_DIST" "$NSIS_NAME"
export NSISDIR
NSISDIR="$(readlink -f "$NSIS_NAME")"

curl -s "$NSIS_RELEASE/$NSIS_SOURCE.tar.bz2" -o "$NSIS_SOURCE.tar.bz2"
tar -xvf "$NSIS_SOURCE.tar.bz2"

if [ "$NSIS_VERSION" == "3.0a2" ]; then
  patch -p1 -i "patches/nsis-3.0a2.patch"
fi

cd "$NSIS_SOURCE"
scons APPEND_CCFLAGS=-fpermissive SKIPSTUBS=all SKIPPLUGINS=all SKIPUTILS=all SKIPMISC=all NSIS_CONFIG_CONST_DATA=no PREFIX="$NSISDIR"  install-compiler

export NSIS_BIN="$NSISDIR/bin/makensis"
chmod +x "$NSIS_BIN"
sudo mkdir -p "/usr/local/bin"
sudo ln -s "$NSIS_BIN" "/usr/local/bin/makensis"

mkdir -p "$NSISDIR/share"
pushd "$NSISDIR/share"
ln -s "$NSISDIR" "$NSIS_NAME"
popd
