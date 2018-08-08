#!/bin/bash -e

source $(dirname "${BASH_SOURCE[0]}")/_base.sh

downloadUrls() {
  grepLink 'https://archive.apache.org/dist/ant/binaries/' 'apache-ant-[0-9.]+-bin\.tar\.gz' | \
    sed 's|^|https://archive.apache.org/dist/ant/binaries/|'
}

downloadUrl() {
  local -r version="${1:?Expected version}"
  downloadUrls | \
    grep "/apache-ant-$version-bin.tar.gz" | \
    head -n 1
}

_sdkvm_versions() {
  downloadUrls | \
    grep -oE 'apache-ant-[^-_]+' | \
    sed 's|apache-ant-||' |
    sort -rV
}

_sdkvm_install() {
  local -r version="$1"
  local -r targetDir="$2"
  extractFromUrl "$(downloadUrl "$version")" "$targetDir"
}

_sdkvm_enable() {
  setupHomeAndPath "ANT" "$2"
}

_sdkvm_disable() {
  resetHomeAndPath "ANT" "$2"
}
