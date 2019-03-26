#!/bin/bash -e

source $(dirname "${BASH_SOURCE[0]}")/_base.sh

adoptOs() {
  case "$(uname -s)" in
    Darwin*) echo "mac";;
    *) echo "linux";;
  esac
}

oracleOs() {
  case "$(uname -s)" in
    Darwin*) echo "osx";;
    *) echo "linux";;
  esac
}

jdkHomeSubDir() {
  case "$(uname -s)" in
    Darwin*) echo "/Contents/Home";;
    *) echo "";;
  esac
}

adoptDownloadUrls() {
  local -r apiBaseUrl="https://api.adoptopenjdk.net/v2/info/releases/openjdk"
  local version=8
  local urls=""
  local -r os="$(adoptOs)"
  while : ; do
    local versionJson="$(curl -s --fail "$apiBaseUrl$version")"
    [[ -n "$versionJson" ]] || break
    local versionUrls="$(echo "$versionJson" | \
      jq -r ".[].binaries[] | select((.os==\"$os\") and (.architecture==\"x64\") and (.binary_type==\"jdk\") and (.openjdk_impl==\"hotspot\")) | .binary_link" 2>/dev/null)"
    urls="$urls $versionUrls"
    version=$((version+1))
  done
  echo -e $urls | \
    sed 's| |\n|g' | \
    tac
}

adoptVersions() {
  adoptDownloadUrls | \
    grep -oE '/jdk.+/' | \
    sed 's|/||g' | \
    sed 's|%2B|+|g' | \
    sed 's|jdk-*||g' | \
    sort -rV
}

oracleDownloadUrls() {
  local -r os="$(oracleOs)"
  local -r versionPages="$(\
    grepLink \
      https://www.oracle.com/technetwork/java/javase/downloads/index.html \
      "([^\"]+/javase/downloads/jdk[^\"]+-downloads[^\"]+)" | \
    sort -u)"
  for versionPageUrl in $versionPages; do
    grepQuotedContent "https://www.oracle.com$versionPageUrl" 'https?://download.oracle.com/[^"]+' | \
      grep -E "$os-x64(_bin)?.tar.gz"
  done
}

oracleVersions() {
  oracleDownloadUrls | \
    grep -oE 'jdk-[^-_]+' | \
    sed 's|^jdk-||' | \
    sort -rV
}

downloadUrl() {
  local -r version="${1:?Expected version}"
  local -r encodedVersion="$(echo "$version" | sed 's|+|%2B|' | sed 's|^[^-]\+-||')"
  local urls=""
  case $version in
    adopt-*)
      urls="$(adoptDownloadUrls)"
      ;;
    oracle-*)
      urls="$(oracleDownloadUrls)"
      ;;
  esac
  echo "$urls" | \
    grep -E "jdk-?$encodedVersion" | \
    head -n 1
}

_sdkvm_versions() {
  adoptVersions | sed 's|^|adopt-|'
  oracleVersions | sed 's|^|oracle-|'
}

_sdkvm_install() {
  local -r version="$1"
  local -r targetDir="$2"
  local -r url="$(downloadUrl "$version")"
  extractFromUrl "$url" "$targetDir" \
    --header "Cookie: oraclelicense=accept-securebackup-cookie"
}

_sdkvm_enable() {
  setupHomeAndPath "JAVA" "$2$(jdkHomeSubDir)"
}

_sdkvm_disable() {
  resetHomeAndPath "JAVA" "$2$(jdkHomeSubDir)"
}