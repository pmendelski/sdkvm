#!/bin/bash -e

source $(dirname "${BASH_SOURCE[0]}")/_base.sh

downloadUrls() {
  curl -s https://www.lua.org/ftp/ | \
    tr '[:upper:]' '[:lower:]' | \
    grep -oE 'href="lua-[0-9].[0-9].[0-9].tar.gz"' | \
    cut -f 2 -d \" | \
    sed -r 's|^(.+)|https://www.lua.org/ftp/\1|'
}

downloadUrl() {
  local -r version="${1:?Expected version}"
  downloadUrls | \
    grep "$version.tar.gz" | \
    head -n 1
}

installDependecnies() {
  installPackages \
    libreadline-dev
}

_sdkvm_versions() {
  downloadUrls | \
    grep -oE 'lua-[0-9.]*[0-9]+' |
    sort -urV
}

_sdkvm_install() {
  local -r version="$1"
  local -r targetDir="$2"
  local -r tmpdir="$(tmpdir_create)"
  installDependecnies
  extractFromUrl "$(downloadUrl "$version")" "$tmpdir"
  cd "$tmpdir"
  make linux | spin
  make install INSTALL_TOP="$targetDir" | spin
  tmpdir_remove "$tmpdir"
}

_sdkvm_enable() {
  setupHomeAndPath "LUA" "$2"
  sdk_eval "export LUA_DIR=\"$2\""
}

_sdkvm_disable() {
  resetHomeAndPath "LUA" "$2"
  sdk_eval "unset LUA_DIR"
}
