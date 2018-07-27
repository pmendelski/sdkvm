#!/bin/bash -e

source $(dirname "${BASH_SOURCE[0]}")/_base.sh

oracleJdkDownloadUrls() {
  local -r versionPages="$(curl -s https://www.oracle.com/technetwork/java/javase/downloads/index.html | \
    grep -oE "href=\"([^\"]+/javase/downloads/jdk[^\"]+-downloads[^\"]+)\"" | \
    cut -f 2 -d \" | \
    sort -u)"
  for versionPageUrl in $versionPages; do
    curl -s "https://www.oracle.com$versionPageUrl" | \
      grep -oE '"https?://download.oracle.com/[^"]+"' | \
      cut -f 2 -d \" | \
      grep -E 'linux-x64(_bin)?.tar.gz'
  done
}

oracleDownloadUrl() {
  local -r oracleVersionPrefix="oracle-jdk-"
  local -r version="${1?Expected version}"
  if [[ "$version" != "${oracleVersionPrefix}"* ]]; then
    error "Unrecognized JDK version: $version. Supported only $oracleVersionPrefix* versions."
  fi
  local -r versionNumber="${version#$oracleVersionPrefix}"
  oracleJdkDownloadUrls | \
    grep "$versionNumber" | \
    head -n 1
}

_sdkvm_versions() {
  oracleJdkDownloadUrls | \
    grep -oE 'jdk-[^-_]+' | \
    sed 's|^|oracle-|' | \
    sort -rV
}

_sdkvm_install() {
  local -r version="$1"
  local -r targetDir="$2"
  local -r downloadUrl="$(oracleDownloadUrl "$version")"
  installFromUrl "jdk" "$version" "$targetDir" "$downloadUrl" \
    "--header 'Cookie: oraclelicense=accept-securebackup-cookie'"
}

_sdkvm_enable() {
  setupHomeAndPath "JAVA" "$2"
}

_sdkvm_disable() {
  resetHomeAndPath "JAVA" "$2"
}
