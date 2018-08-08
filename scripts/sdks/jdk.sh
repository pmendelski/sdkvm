#!/bin/bash -e

source $(dirname "${BASH_SOURCE[0]}")/_base.sh

openJdkDownloadUrls() {
  local -r versionPages="$( \
    grepLink http://jdk.java.net/ ".?/java-se-ri/[0-9]+" | \
    sed 's|./|/|')"
  for versionPageUrl in $versionPages; do
    grepQuotedContent \
      "http://jdk.java.net/$versionPageUrl" \
      'https://download.java.net/openjdk/jdk[^/]*/ri/jdk[^"/]+[_-]linux-x64[_-][^"/]*.(tar.gz|zip)'
  done
}

openJdkDownloadUrl() {
  local -r version="${1:?Expected version}"
  openJdkDownloadUrls | \
    grep "$version" | \
    head -n 1
}

openJdkVersions() {
  openJdkDownloadUrls | \
    grep -oE 'jdk(_ri)?-[^-_]+' | \
    sed -E 's|^[^-]+|openjdk|'
}

oracleDownloadUrls() {
  local -r versionPages="$(\
    grepLink \
      https://www.oracle.com/technetwork/java/javase/downloads/index.html \
      "([^\"]+/javase/downloads/jdk[^\"]+-downloads[^\"]+)" | \
    sort -u)"
  for versionPageUrl in $versionPages; do
    grepQuotedContent "https://www.oracle.com$versionPageUrl" 'https?://download.oracle.com/[^"]+' | \
      grep -E 'linux-x64(_bin)?.tar.gz'
  done
}

oracleDownloadUrl() {
  local -r oracleVersionPrefix="oracle-"
  local -r version="${1:?Expected version}"
  oracleDownloadUrls | \
    grep "$version" | \
    head -n 1
}

oracleVersions() {
  oracleDownloadUrls | \
    grep -oE 'jdk-[^-_]+' | \
    sed 's|^jdk-||' | \
    sort -rV
}

downloadUrl() {
  local -r version="${1:?Expected version}"
  case $version in
    openjdk-*)
      openJdkDownloadUrl "${version#openjdk-}"
      ;;
    *)
      oracleDownloadUrl "$version"
      ;;
  esac
}

_sdkvm_versions() {
  oracleVersions
  # TODO: Add caching for version fetching and parsing
  # openJdkVersions is too slow
  # openJdkVersions
}

_sdkvm_install() {
  local -r version="$1"
  local -r targetDir="$2"
  local -r url="$(downloadUrl "$version")"
  extractFromUrl "$url" "$targetDir" \
    --header "Cookie: oraclelicense=accept-securebackup-cookie"
}

_sdkvm_enable() {
  setupHomeAndPath "JAVA" "$2"
}

_sdkvm_disable() {
  resetHomeAndPath "JAVA" "$2"
}
