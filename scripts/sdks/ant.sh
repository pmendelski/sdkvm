#!/bin/bash -e

source $(dirname "${BASH_SOURCE[0]}")/_base.sh

antDownloadUrls() {
  curl -s 'https://archive.apache.org/dist/ant/binaries/' | \
    grep -oE 'href="apache-ant-[0-9.]+-bin\.tar\.gz"' | \
    cut -f 2 -d \" | \
    sed 's|^|https://archive.apache.org/dist/ant/binaries/|'
}

antDownloadUrl() {
  local -r version="${1?Expected version}"
  local -r urlVersion="${version/ant-/apache-ant-}"
  antDownloadUrls | \
    grep "/$urlVersion-bin.tar.gz" | \
    head -n 1
}

_sdkvm_versions() {
  antDownloadUrls | \
    grep -oE 'apache-ant-[^-_]+' | \
    sed 's|apache-ant-|ant-|' |
    sort -rV
}

_sdkvm_install() {
  local -r version="$1"
  local -r targetDir="$2"
  local -r downloadUrl="$(antDownloadUrl "$version")"
  installFromUrl "ant" "$version" "$targetDir" "$downloadUrl"
}

_sdkvm_enable() {
  setupHomeAndPath "ANT" "$2"
}

_sdkvm_disable() {
  resetHomeAndPath "ANT" "$2"
}
