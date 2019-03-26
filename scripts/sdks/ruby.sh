#!/bin/bash -e

source $(dirname "${BASH_SOURCE[0]}")/_base.sh

downloadUrls() {
  curl -s https://cache.ruby-lang.org/pub/ruby/index.txt | \
    grep "^ruby-[0-9].[0-9].[0-9][^-]" |
    grep -oE "https://.+.tar.gz"
}

downloadUrl() {
  local -r version="${1:?Expected version}"
  downloadUrls | \
    grep "ruby-$version.tar.gz" | \
    head -n 1
}

_sdkvm_versions() {
  downloadUrls | \
    grep -oE 'ruby-[0-9.]*[0-9]+' |
    sed 's|^ruby-||' |
    sort -urV
}

_sdkvm_install() {
  local -r version="$1"
  local -r targetDir="$2"
  buildFromUrl "$(downloadUrl "$version")" "$targetDir" \
    "--disable-install-doc"
}

_sdkvm_enable() {
  setupHomeAndPath "RUBY" "$2"
}

_sdkvm_disable() {
  resetHomeAndPath "RUBY" "$2"
}
