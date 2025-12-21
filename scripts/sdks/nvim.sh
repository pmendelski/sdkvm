#!/usr/bin/env bash
set -e

source "$(dirname "${BASH_SOURCE[0]}")/_base.sh"

downloadUrls() {
  local pkgsys="linux"
  local pkgarch="x86_64"
  if [ "$SYSTYPE" == "darwin" ]; then
    pkgsys="macos"
  fi
  if [ "$ARCHTYPE" == "arm64" ]; then
    pkgarch="arm64"
  fi
  local p1="$(ccurl -s 'https://api.github.com/repos/neovim/neovim/releases?per_page=50')"
  echo -e "$p1" |
    grep -oE "\"https://github.com/neovim/neovim/releases/download/v[0-9.]*/nvim-$pkgsys-$pkgarch.tar.gz\"" |
    grep -oE '[^"]+' |
    sort -Vu
}

downloadUrl() {
  local -r version="${1:?Expected version}"
  downloadUrls |
    grep "/v$version" |
    tail -n 1
}

_sdkvm_versions() {
  downloadUrls |
    grep -oE '/v[0-9.]+' |
    grep -oE '[0-9.]+$'
}

_sdkvm_install() {
  local -r version="$1"
  local -r targetDir="$2"
  extractFromUrl "$(downloadUrl "$version")" "$targetDir"
}

_sdkvm_enable() {
  setupHomeAndPath "NVIM" "$2"
}

_sdkvm_disable() {
  resetHomeAndPath "NVIM" "$2"
}
