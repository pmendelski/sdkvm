#!/usr/bin/env bash
set -e

source "$(dirname "${BASH_SOURCE[0]}")/_base.sh"

downloadUrls() {
  local pkgsys="debian"
  if [ "$SYSTYPE" = "darwin" ]; then
    pkgsys="macos"
  fi
  local pkgarch="x86_64"
  if [ "$ARCHTYPE" = "arm64" ]; then
    pkgarch="arm64"
  fi
  local pattern="https://fastdl.mongodb.org/${pkgsys//^macos$/osx}/mongodb-$pkgsys-$pkgarch-.*-[0-9]*\.[0-9]*\.[0-9]*\.tgz"
  if [ "$pkgsys" = "macos" ]; then
    pattern="https://fastdl.mongodb.org/osx/mongodb-$pkgsys-$pkgarch-[0-9]*\.[0-9]*\.[0-9]*\.tgz"
  fi
  ccurl -s "https://www.mongodb.com/try/download/community-edition/releases" |
    grep -oP "$pattern" |
    sort -ru
}

downloadUrl() {
  local -r version="${1:?Expected version}"
  downloadUrls |
    grep "$version.tgz" |
    head -n 1
}

_sdkvm_versions() {
  downloadUrls |
    grep -oE "[0-9.]*.tgz$" |
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
