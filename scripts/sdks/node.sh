#!/bin/bash -e

source $(dirname "${BASH_SOURCE[0]}")/_base.sh

nodeDownloadUrls() {
  curl -s https://nodejs.org/en/download/releases/ | \
    grep -oE 'href="https://nodejs.org/download/release/v[0-9.]+/"' | \
    grep -oE "v[0-9.]+" | \
    sed -r 's|^(.+)|https://nodejs.org/download/release/\1/node-\1-linux-x64.tar.gz|'
}

nodeDownloadUrl() {
  local -r version="${1?Expected version}"
  local -r urlVersion="${version/nodejs-/nodejs-v}"
  nodeDownloadUrls | \
    grep "$urlVersion-" | \
    head -n 1
}

_sdkvm_versions() {
  nodeDownloadUrls | \
    grep -oE 'node-v[^-_]+' |
    sed 's|node-v|node-|' | \
    sort -rV
}

_sdkvm_install() {
  local -r version="$1"
  local -r targetDir="$2"
  local -r downloadUrl="$(nodeDownloadUrl "$version")"
  installFromUrl "node" "$version" "$targetDir" "$downloadUrl"
}

_sdkvm_enable() {
  setupHomeAndPath "NODE" "$2"
}

_sdkvm_disable() {
  resetHomeAndPath "NODE" "$2"
}
