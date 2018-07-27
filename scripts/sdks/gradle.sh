#!/bin/bash -e

source $(dirname "${BASH_SOURCE[0]}")/_base.sh

gradleDownloadUrls() {
  curl -s https://services.gradle.org/distributions/ | \
    grep -oE 'href="(/distributions/gradle-[0-9.]+-bin.zip)"' | \
    cut -f 2 -d \" | \
    sed 's|^|https://services.gradle.org|'
}

_sdkvm_versions() {
  gradleDownloadUrls | \
    grep -oE 'gradle-[^-_]+'
}

gradleDownloadUrl() {
  local -r version="${1?Expected version}"
  gradleDownloadUrls | \
    grep "/$version-bin.zip" | \
    head -n 1
}

_sdkvm_install() {
  local -r version="$1"
  local -r targetDir="$2"
  local -r downloadUrl="$(gradleDownloadUrl "$version")"
  installFromUrl "gradle" "$version" "$targetDir" "$downloadUrl"
}

_sdkvm_enable() {
  local -r sdkDir="$2"
  exec "export _SDKVM_GRADLE_HOME_PREV=\"$GRADLE_HOME\""
  exec "export GRADLE_HOME=\"$sdkDir\""
  exec "export PATH=\"$(path_add "$sdkDir/bin")\""
}

_sdkvm_disable() {
  local -r sdkDir="$2"
  exec "export GRADLE_HOME=\"$_SDKVM_GRADLE_HOME_PREV\""
  exec "unset _SDKVM_GRADLE_HOME_PREV"
  exec "export PATH=\"$(path_remove "$sdkDir/bin")\""
}

gradleDownloadUrls
