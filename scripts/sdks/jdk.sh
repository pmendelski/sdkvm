#!/usr/bin/env bash
set -e

source "$(dirname "${BASH_SOURCE[0]}")/_base.sh"

temurinOs() {
  case "$(uname -s)" in
  Darwin*) echo "mac" ;;
  *) echo "linux" ;;
  esac
}

downloadUrls() {
  ccurl -s "https://api.adoptium.net/v3/assets/version/%281%2C100%29?image_type=jdk&page=0&page_size=100&project=jdk&release_type=ga&os=$(temurinOs)&architecture=x64" |
    jq -r ".[].binaries[0].package.link"
}

_sdkvm_versions() {
  downloadUrls |
    grep -oE '/jdk[-8].+/' |
    sed 's|/||g' |
    sed 's|%2B|+|g' |
    sed 's|jdk-*||g' |
    sed 's|jdk*||g' |
    sort -rV
}

downloadUrl() {
  local -r version="${1:?Expected version}"
  local -r encodedVersion="${version//+/%2B}"
  downloadUrls |
    grep -E "jdk-?$encodedVersion" |
    head -n 1
}

_sdkvm_install() {
  local -r version="$1"
  local -r targetDir="$2"
  local -r url="$(downloadUrl "$version")"
  extractFromUrl "$url" "$targetDir"
}

jdkHomeSubDir() {
  case "$(uname -s)" in
  Darwin*) echo "/Contents/Home" ;;
  *) echo "" ;;
  esac
}

_sdkvm_enable() {
  setupHomeAndPath "JAVA" "$2$(jdkHomeSubDir)"
}

_sdkvm_disable() {
  resetHomeAndPath "JAVA" "$2$(jdkHomeSubDir)"
}
