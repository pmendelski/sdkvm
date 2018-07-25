#!/bin/bash -e

source $(dirname "${BASH_SOURCE[0]}")/_base.sh

jdkVersionPageUrls() {
  curl -s https://www.oracle.com/technetwork/java/javase/downloads/index.html | \
    grep -oE "href=\"([^\"]+/javase/downloads/jdk[^\"]+-downloads[^\"]+)\"" | \
    cut -f 2 -d \" | \
    sort -u
}

_sdkvm_fetch_versions() {
  jdkVersionPageUrls | \
    grep -oE "jdk([0-9]+)" | \
    grep -oE "[0-9]+"
}

_sdkvm_fetch_download_url() {
  local -r version="${1?Expected version}"
  local -r jdkDownloadPageUrl="$(jdkVersionPageUrls | grep "jdk$version-downloads" | head -n 1)"
  if [ -z "$jdkDownloadPageUrl" ]; then
    error "Could not locate download page url for JDK v$version"
  fi
  curl -s "https://www.oracle.com/$jdkDownloadPageUrl" | \
    grep -oE "\"(https?://download.oracle.com/[^\"]+)\"" | \
    grep "linux" | \
    grep ".tar.gz" | \
    cut -f 2 -d \" | \
    sort -u |
    head -n 1
}

_sdkvm_install() {
  local -r version="$1"
  local -r targetDir="$2"
  local -r downloadUrl="$3"
  local -r file="${downloadUrl##*/}"
  local -r tmpdir="$(tmpdir_create "$version")"
  cd "$tmpdir"
  printDebug "Downloading JDK $version from $downloadUrl to $tmpdir"
  wget -q --show-progress \
    --no-check-certificate --no-cookies \
    --header "Cookie: oraclelicense=accept-securebackup-cookie" \
    -O "$file" "$downloadUrl"
  printTrace "Download completed"
  printDebug "Installing JDK from $tmpdir"
  extract "$file" "$targetDir"
  printTrace "Installation completed"
  tmpdir_remove "$tmpdir"
  printTrace "Temporary files removed"
}

_sdkvm_enable() {
  local -r sdkDir="$2"
  exec "export _SDKVM_JAVA_HOME_PREV=\"$JAVA_HOME\""
  exec "export JAVA_HOME=\"$sdkDir\""
  exec "export PATH=\"$(path_add "$sdkDir/bin")\""
}

_sdkvm_disable() {
  local -r sdkDir="$2"
  exec "export JAVA_HOME=\"$_SDKVM_JAVA_HOME_PREV\""
  exec "unset _SDKVM_JAVA_HOME_PREV"
  exec "export PATH=\"$(path_remove "$sdkDir/bin")\""
}
