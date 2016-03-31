#!/bin/bash
# martinec
set -eo pipefail

install() {
  local filename="$1"
  wget "http://mirrors.kernel.org/ubuntu/pool/universe/n/nsis/$filename"
  #sudo dpkg -i "$filename"
}

install "nsis-common_2.50-1_all.deb"
install "nsis_2.50-1_amd64.deb"
install "nsis-pluginapi_2.50-1_all.deb"


