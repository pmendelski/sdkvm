#!/usr/bin/env bash
set -e

source $(dirname "${BASH_SOURCE[0]}")/_base.sh

go_systype() {
  case "$OSTYPE" in
    linux*)   echo "linux" ;;
    darwin*)  echo "darwin" ;;
  esac
}

downloadUrls() {
  grepLink "https://golang.org/dl/" "/dl/go[0-9.]+$(go_systype)-amd64.tar.gz" | \
    sed 's|^|https://golang.org|'
}

downloadUrl() {
  local -r version="${1:?Expected version}"
  downloadUrls | \
    grep "/go$version.$(go_systype)-amd64.tar.gz" | \
    head -n 1
}

_sdkvm_versions() {
  downloadUrls | \
    grep -oE 'go[^a-z]+\.' | \
    sed 's|^go||' | \
    sed 's|.$||'
}

_sdkvm_install() {
  local -r version="$1"
  local -r targetDir="$2"
  extractFromUrl "$(downloadUrl "$version")" "$targetDir"
}

_sdkvm_enable() {
  setupHomeAndPath "GO" "$2"
}

_sdkvm_disable() {
  resetHomeAndPath "GO" "$2"
}

