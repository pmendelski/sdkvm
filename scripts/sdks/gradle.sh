#!/usr/bin/env bash
set -e

source $(dirname "${BASH_SOURCE[0]}")/_base.sh

downloadUrls() {
  grepLink "https://services.gradle.org/distributions/" '/distributions/gradle-[0-9.]+-bin.zip' | \
    sed 's|^|https://services.gradle.org|'
}

downloadUrl() {
  local -r version="${1:?Expected version}"
  downloadUrls | \
    grep "/gradle-$version-bin.zip" | \
    head -n 1
}

_sdkvm_versions() {
  downloadUrls | \
    grep -oE 'gradle-[^-_]+' | \
    sed 's|^gradle-||'
}

_sdkvm_install() {
  local -r version="$1"
  local -r targetDir="$2"
  extractFromUrl "$(downloadUrl "$version")" "$targetDir"
}

_sdkvm_enable() {
  setupHomeAndPath "GRADLE" "$2"
}

_sdkvm_disable() {
  resetHomeAndPath "GRADLE" "$2"
}
