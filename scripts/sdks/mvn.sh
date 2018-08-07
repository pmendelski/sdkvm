#!/bin/bash -e

source $(dirname "${BASH_SOURCE[0]}")/_base.sh

downloadUrls() {
  curl -s 'https://archive.apache.org/dist/maven/maven-3/' | \
    grep -oE 'href="[0-9.]+/?"' | \
    cut -f 2 -d \" | \
    grep -oE '[0-9.]+' | \
    sed -r 's|^(.+)|https://archive.apache.org/dist/maven/maven-3/\1/binaries/apache-maven-\1-bin.tar.gz|' |
    sort -r
}

downloadUrl() {
  local -r version="${1?Expected version}"
  local -r urlVersion="${version/mvn-/apache-maven-}"
  downloadUrls | \
    grep "/$urlVersion-bin.tar.gz" | \
    head -n 1
}

_sdkvm_versions() {
  downloadUrls | \
    grep -oE 'apache-maven-[^-_]+' | \
    sed 's|apache-maven-|mvn-|' | \
    sort -rV
}

_sdkvm_install() {
  local -r version="$1"
  local -r targetDir="$2"
  extractFromUrl "$(downloadUrl "$version")" "$targetDir"
}

_sdkvm_enable() {
  setupHomeAndPath "MVN" "$2"
}

_sdkvm_disable() {
  resetHomeAndPath "MVN" "$2"
}
