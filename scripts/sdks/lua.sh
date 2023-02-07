#!/usr/bin/env bash
set -e

source $(dirname "${BASH_SOURCE[0]}")/_base.sh

luaOs() {
  case "$(uname -s)" in
    Darwin*) echo "macosx";;
    *) echo "linux";;
  esac
}

downloadUrls() {
  grepLink 'https://www.lua.org/ftp/' 'lua-[0-9].[0-9].[0-9].tar.gz' | \
    sed -r 's|^(.+)|https://www.lua.org/ftp/\1|'
}

downloadUrl() {
  local -r version="${1:?Expected version}"
  downloadUrls | \
    grep "lua-$version.tar.gz" | \
    head -n 1
}

installDependecnies() {
  installPackages \
    libreadline-dev
}

_sdkvm_versions() {
  downloadUrls | \
    grep -oE 'lua-[0-9.]*[0-9]+' |
    sed 's|^lua-||' |
    sort -urV
}

_sdkvm_install() {
  local -r version="$1"
  local -r targetDir="$2"
  local -r tmpdir="$(tmpdir_create)"
  local -r os="$(luaOs)"
  # installDependecnies
  extractFromUrl "$(downloadUrl "$version")" "$tmpdir"
  cd "$tmpdir"
  make $os | spin
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
