#!/bin/bash
# martinec
set -eo pipefail

NSIS_VERSION="3.0a2"
NSIS_DIST="nsis-$NSIS_VERSION"
NSIS_SOURCE="$NSIS_DIST-src"
NSIS_MIRROR="http://iweb.dl.sourceforge.net/project/nsis"
NSIS_RELEASE="$NSIS_MIRROR/NSIS%203%20Pre-release/$NSIS_VERSION"

patch_3_0a2() {
cat << EOF
diff a/nsis-3.0a2-src-patch/Source/winchar.cpp b/nsis-3.0a2-src/Source/winchar.cpp
--- a/nsis-3.0a2-src/Source/winchar.cpp
+++ b/nsis-3.0a2-src/Source/winchar.cpp
@@ -94,7 +94,7 @@
   unsigned int v = 0, base = 10, top = '9';
   int sign = 1;
   if (*s == _T('-')) ++s, sign = -1;
-  for ( unsigned short int c;; )
+  for ( unsigned int c;; )
   {
     if ((c = *s++) >= '0' && c <= top) c -= '0'; else break;
     v *= base, v += c;
diff a/nsis-3.0a2-src-patch/Source/writer.cpp b/nsis-3.0a2-src/Source/writer.cpp
--- a/nsis-3.0a2-src/Source/writer.cpp
+++ b/nsis-3.0a2-src/Source/writer.cpp
@@ -57,7 +57,7 @@
   if (m_build_unicode)
   {
     bool strEnd = false;
-    TCHAR ch = _T('\0');
+    TCHAR ch;
     for (; size ; size--)
     {
       if (!strEnd)
EOF
}

curl -s "$NSIS_RELEASE/$NSIS_DIST.zip" -o "$NSIS_DIST.zip"
unzip "$NSIS_DIST"
export NSISDIR="$(readlink -f "$NSIS_DIST")"

curl -s "$NSIS_RELEASE/$NSIS_SOURCE.tar.bz2" -o "$NSIS_SOURCE.tar.bz2"
tar -xvf "$NSIS_SOURCE.tar.bz2"

patch_3_0a2 | patch -p1 -i -

cd "$NSIS_SOURCE"
scons SKIPSTUBS=all SKIPPLUGINS=all SKIPUTILS=all SKIPMISC=all NSIS_CONFIG_CONST_DATA=no PREFIX="$NSISDIR"  install-compiler

export NSIS_BIN="$NSISDIR/bin/makensis"
