#!/usr/bin/env bash
set -e

source $(dirname "${BASH_SOURCE[0]}")/_base.sh

mongoOs() {
  case "$(uname -s)" in
    Darwin*) echo "osx";;
    *) echo "linux";;
  esac
}

downloadUrls() {
  local -r os="$(mongoOs)"
  ccurl -s "https://www.mongodb.com/download-center/community/releases" | \
    grep -oP "https://fastdl.mongodb.org/$os/mongodb-$os-x86_64-[0-9]*\.[0-9]*\.[0-9]*\.tgz" | \
    sort -ru
}

downloadUrl() {
  local -r os="$(mongoOs)"
  local -r version="${1:?Expected version}"
  downloadUrls | \
    grep "/mongodb-$os-x86_64-$version.tgz" | \
    head -n 1
}

_sdkvm_versions() {
  local -r os="$(mongoOs)"
  downloadUrls | \
    grep -oE "mongodb-$os-x86_64-[^-_]+" | \
    sed "s|^mongodb-$os-x86_64-||" | \
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
