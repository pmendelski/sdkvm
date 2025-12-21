#!/usr/bin/env bash
set -e

source "$(dirname "${BASH_SOURCE[0]}")/_base.sh"

downloadUrls() {
  ccurl -s "https://kafka.apache.org/community/downloads/" |
    grep -oE '/kafka/[0-9.]+/kafka_[0-9.-]+\.tgz' |
    sed 's|^|https://dlcdn.apache.org|' |
    sort -ru
}

downloadUrl() {
  local -r version="${1:?Expected version}"
  downloadUrls |
    grep -E "/kafka_[0-9.]+-$version.tgz" |
    tail -n 1
}

_sdkvm_versions() {
  downloadUrls |
    grep -oE 'kafka_[0-9.-]+' |
    grep -oE '[0-9.]+$' |
    sed 's|.$||'
}

_sdkvm_install() {
  local -r version="$1"
  local -r targetDir="$2"
  extractFromUrl "$(downloadUrl "$version")" "$targetDir"
}

_sdkvm_enable() {
  setupHomeAndPath "KAFKA" "$2"
}

_sdkvm_disable() {
  resetHomeAndPath "KAFKA" "$2"
}
