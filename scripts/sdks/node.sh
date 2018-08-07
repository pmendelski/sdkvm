#!/bin/bash -e

source $(dirname "${BASH_SOURCE[0]}")/_base.sh

downloadUrls() {
  curl -s https://nodejs.org/en/download/releases/ | \
    grep -oE 'href="https://nodejs.org/download/release/v[0-9.]+/"' | \
    grep -oE "v[0-9.]+" | \
    sed -r 's|^(.+)|https://nodejs.org/download/release/\1/node-\1-linux-x64.tar.gz|'
}

downloadUrl() {
  local -r version="${1:?Expected version}"
  local -r urlVersion="${version/node-/node-v}"
  downloadUrls | \
    grep "$urlVersion-" | \
    head -n 1
}

_sdkvm_versions() {
  downloadUrls | \
    grep -oE 'node-v[^-_]+' |
    sed 's|node-v|node-|' | \
    sort -rV
}

_sdkvm_install() {
  local -r version="$1"
  local -r targetDir="$2"
  extractFromUrl "$(downloadUrl "$version")" "$targetDir"
}

_sdkvm_enable() {
  setupHomeAndPath "NODE" "$2"
}

_sdkvm_disable() {
  resetHomeAndPath "NODE" "$2"
}
