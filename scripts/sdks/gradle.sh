#!/bin/bash -e

source $(dirname "${BASH_SOURCE[0]}")/_base.sh

gradleDownloadUrls() {
  curl -s https://services.gradle.org/distributions/ | \
    grep -oE 'href="(/distributions/gradle-[0-9.]+-bin.zip)"' | \
    cut -f 2 -d \" | \
    sed 's|^|https://services.gradle.org|'
}

gradleDownloadUrl() {
  local -r version="${1?Expected version}"
  gradleDownloadUrls | \
    grep "/$version-bin.zip" | \
    head -n 1
}

_sdkvm_versions() {
  gradleDownloadUrls | \
    grep -oE 'gradle-[^-_]+'
}

_sdkvm_install() {
  local -r version="$1"
  local -r targetDir="$2"
  local -r downloadUrl="$(gradleDownloadUrl "$version")"
  installFromUrl "gradle" "$version" "$targetDir" "$downloadUrl"
}

_sdkvm_enable() {
  setupHomeAndPath "GRADLE" "$2"
}

_sdkvm_disable() {
  resetHomeAndPath "GRADLE" "$2"
}
