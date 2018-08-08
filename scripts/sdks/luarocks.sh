#!/bin/bash -e

source $(dirname "${BASH_SOURCE[0]}")/_base.sh

downloadUrls() {
  curl -s http://luarocks.github.io/luarocks/releases/ | \
    grep -oE 'href="luarocks-[0-9].[0-9].[0-9].tar.gz"' | \
    cut -f 2 -d \" | \
    sed -r 's|^(.+)|http://luarocks.github.io/luarocks/releases/\1|'
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
    grep -oE 'luarocks-[0-9.]*[0-9]+' |
    sort -urV
}

_sdkvm_install() {
  local -r version="$1"
  local -r targetDir="$2"
  local -r luaVersion="$(sdk_getEnabledVersion lua | grep -oE "[0-9].[0-9]")"
  local -r tmpdir="$(tmpdir_create)"
  sdk_isEnabled "lua" || error "Before installing luarocks make sure lua is enabled."
  installDependecnies
  extractFromUrl "$(downloadUrl "$version")" "$tmpdir"
  cd "$tmpdir"
  ./configure --prefix="$targetDir" --lua-version="$luaVersion" | spin
  make build | spin
  make install | spin
  tmpdir_remove "$tmpdir"
}

_sdkvm_enable() {
  setupHomeAndPath "LUAROCKS" "$2"
}

_sdkvm_disable() {
  resetHomeAndPath "LUAROCKS" "$2"
}
