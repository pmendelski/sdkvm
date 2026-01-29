#!/usr/bin/env bash
set -e

source "$(dirname "${BASH_SOURCE[0]}")/_base.sh"

downloadUrls() {
  grepLink "https://go.dev/dl/" "/dl/go[0-9.]+$SYSTYPE-$ARCHTYPE.tar.gz" |
    sed 's|^|https://go.dev|'
}

downloadUrl() {
  local -r version="${1:?Expected version}"
  downloadUrls |
    grep "/go$version.$SYSTYPE-$ARCHTYPE.tar.gz" |
    head -n 1
}

_sdkvm_versions() {
  downloadUrls |
    grep -oE 'go[^a-z]+\.' |
    sed 's|^go||' |
    sed 's|.$||'
}

_sdkvm_install() {
  local -r version="$1"
  local -r targetDir="$2"
  extractFromUrl "$(downloadUrl "$version")" "$targetDir"
}

_sdkvm_installPackage() {
  local -r pkg="${1?Expected package}"
  if [[ "$pkg" =~ "@" ]]; then
    go install "$pkg"
  else
    go install "$pkg@latest"
  fi
}

_sdkvm_enable() {
  setupHomeAndPath "GO" "$2"
  setupVariableWithBackup "GOMODCACHE" "$3/mod"
  setupVariableWithBackup "GOBIN" "$3/bin"
  addToPath "$3/bin"
}

_sdkvm_disable() {
  resetHomeAndPath "GO" "$2"
  restorePreviousValue "GOMODCACHE"
  restorePreviousValue "GOBIN"
  removeFromPath "$3/bin"
}
