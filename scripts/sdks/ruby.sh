#!/bin/bash -e

source $(dirname "${BASH_SOURCE[0]}")/_base.sh

rubyDownloadUrls() {
  curl -s https://cache.ruby-lang.org/pub/ruby/index.txt | \
    grep "^ruby-[0-9].[0-9].[0-9][^-]" |
    grep -oE "https://.+.tar.gz"
}

rubyDownloadUrl() {
  local -r version="${1?Expected version}"
  rubyDownloadUrls | \
    grep "$version.tar.gz" | \
    head -n 1
}

_sdkvm_versions() {
  rubyDownloadUrls | \
    grep -oE 'ruby-[0-9.]*[0-9]+' |
    sort -urV
}

# TODO: Compare with https://github.com/docker-library/ruby/blob/eca972d167cf4291de898e85aaf50d9a1929d4c7/2.5/alpine3.7/Dockerfile
# TODO: Use tmpdir instead of -src dir
# TODO: compare with python
# TODO: Add lua
# TODO: Add skvm update command
# TODO: Check completion (sorting issue)
_sdkvm_install() {
  local -r version="$1"
  local -r sourcesDir="$2-src"
  local -r targetDir="$2"
  local -r downloadUrl="$(rubyDownloadUrl "$version")"
  installFromUrl "ruby" "$version" "$sourcesDir" "$downloadUrl"
  installPackages build-essential
  cd "$sourcesDir"
  ./configure --prefix="$targetDir" --disable-install-doc --build="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)"
  make -j "$(nproc)"
  make install
  rm -rf "$sourcesDir"
}

_sdkvm_enable() {
  setupHomeAndPath "RUBY" "$2"
}

_sdkvm_disable() {
  resetHomeAndPath "RUBY" "$2"
}
