#!/usr/bin/env bash
set -e

source "$(dirname "${BASH_SOURCE[0]}")/_base.sh"

downloadUrls() {
  ccurl -s "http://download.redis.io/releases/" |
    grep -oP "redis-[0-9]+(\.[0-9]+)*(-[^.-]+)*\.tar.gz" |
    sed "s|^redis-|http://download.redis.io/releases/redis-|" |
    sort -ru
}

downloadUrl() {
  local -r version="${1:?Expected version}"
  downloadUrls |
    grep "/releases/redis-$version.tar.gz" |
    head -n 1
}

_sdkvm_versions() {
  downloadUrls |
    grep -oE "redis-[0-9]+(\.[0-9]+)*(-[^.-]+)*" |
    sed "s|^redis-||" |
    sed 's|.tar.gz$||'
}

_sdkvm_install() {
  local -r version="$1"
  local -r targetDir="$2"
  local -r tmpdir="$(tmpdir_create)"
  extractFromUrl "$(downloadUrl "$version")" "$tmpdir"
  cd "$tmpdir"
  make | spin
  chmod 755 src/redis-cli
  mkdir -p "$targetDir/bin"
  mv src/redis-cli "$targetDir/bin/redis-cli"
  tmpdir_remove "$tmpdir"
}

_sdkvm_enable() {
  setupHomeAndPath "REDIS" "$2"
}

_sdkvm_disable() {
  resetHomeAndPath "REDIS" "$2"
}
