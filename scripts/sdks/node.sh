#!/bin/bash -e

source $(dirname "${BASH_SOURCE[0]}")/_base.sh

gradleDownloadUrls() {
  curl -s https://nodejs.org/en/download/releases/ | \
    grep -oE 'href="https://nodejs.org/download/release/v[0-9.]+/"' | \
    grep -oE "v[0-9.]+" | \
    sed -r 's|^(.+)|https://nodejs.org/en/download/releases/\1/nodejs-\1-linux-x64.tar.gz|'
}

nodeDownloadUrl() {
  local -r version="${1?Expected version}"
  gradleDownloadUrls | \
    grep "/$version-bin.zip" | \
    head -n 1
}

_sdkvm_versions() {
  gradleDownloadUrls | \
    grep -oE 'gradle-[^-_]+'
}

_sdkvm_install() {
  local -r version="$1"
  local -r targetDir="$2"
  local -r downloadUrl="$(nodeDownloadUrl "$version")"
  installFromUrl "node" "$version" "$targetDir" "$downloadUrl"
}

_sdkvm_enable() {
  local -r sdkDir="$2"
  exec "export _SDKVM_NODE_HOME_PREV=\"$NODE_HOME\""
  exec "export NODE_HOME=\"$sdkDir\""
  exec "export PATH=\"$(path_add "$sdkDir/bin")\""
}

_sdkvm_disable() {
  local -r sdkDir="$2"
  exec "export NODE_HOME=\"$_SDKVM_NODE_HOME_PREV\""
  exec "unset _SDKVM_NODE_HOME_PREV"
  exec "export PATH=\"$(path_remove "$sdkDir/bin")\""
}
