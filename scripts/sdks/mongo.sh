#!/bin/bash -e

source $(dirname "${BASH_SOURCE[0]}")/_base.sh

downloadUrls() {
  curl -s "https://www.mongodb.com/download-center/community" | \
    grep -oP "https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-[0-9]*\.[0-9]*\.[0-9]*\.tgz" | \
    sort -ru
}

downloadUrl() {
  local -r version="${1:?Expected version}"
  downloadUrls | \
    grep "/mongodb-linux-x86_64-$version.tgz" | \
    head -n 1
}

_sdkvm_versions() {
  downloadUrls | \
    grep -oE 'mongodb-linux-x86_64-[^-_]+' | \
    sed 's|^mongodb-linux-x86_64-||' | \
    sed 's|.tgz$||'
}

_sdkvm_install() {
  local -r version="$1"
  local -r targetDir="$2"
  extractFromUrl "$(downloadUrl "$version")" "$targetDir"
}

_sdkvm_enable() {
  setupHomeAndPath "MONGO" "$2"
}

_sdkvm_disable() {
  resetHomeAndPath "MONGO" "$2"
}
