#!/bin/bash
# martinec
set -eo pipefail

install() {
  local filename="$1"
  wget "http://mirrors.kernel.org/ubuntu/pool/universe/n/nsis/$filename"
  sudo dpkg -i "$filename"
}

compile() {
  local filename="$1"
  wget "http://archive.ubuntu.com/ubuntu/pool/universe/n/nsis/$filename"
  tar -xvf "$1"
  dpkg-buildpackage -us -uc
}

install "nsis-common_2.50-1_all.deb"
compile "nsis_2.50-1.debian.tar.xz"
install "nsis-pluginapi_2.50-1_all.deb"


