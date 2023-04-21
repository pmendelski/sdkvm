#!/usr/bin/env bash
set -e

source "$(dirname "${BASH_SOURCE[0]}")/_base.sh"

downloadUrls() {
  local pkgsys="linux"
  local pkgarch="x86_64"
  if [ "$SYSTYPE" == "darwin" ]; then
    pkgsys="osx"
  fi
  if [ "$ARCHTYPE" == "arm64" ]; then
    pkgarch="aarch_64"
  fi
  ccurl -s 'https://api.github.com/repos/protocolbuffers/protobuf/releases' |
    grep -oE "\"protoc-[0-9.]*-$pkgsys-$pkgarch.zip\"" |
    grep -oE '[^"]+' |
    sort -Vu |
    sed -e "s|protoc-\([^-]\+\)-\(.\+\)|https://github.com/protocolbuffers/protobuf/releases/download/v\1/protoc-\1-\2|"
}

downloadUrl() {
  local -r version="${1:?Expected version}"
  downloadUrls |
    grep -E "/protoc-$version-.*.zip" |
    tail -n 1
}

_sdkvm_versions() {
  downloadUrls |
    grep -oE 'protoc-[0-9.]+' |
    grep -oE '[0-9.]+$'
}

_sdkvm_install() {
  local -r version="$1"
  local -r targetDir="$2"
  extractFromUrl "$(downloadUrl "$version")" "$targetDir"
}

_sdkvm_enable() {
  setupHomeAndPath "PROTOC" "$2"
}

_sdkvm_disable() {
  resetHomeAndPath "PROTOC" "$2"
}
