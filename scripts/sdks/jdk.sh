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
    sed 's|^|oracle-|'
}

_sdkvm_install() {
  local -r version="$1"
  local -r targetDir="$2"
  local -r downloadUrl="$(oracleDownloadUrl "$version")"
  installFromUrl "jdk" "$version" "$targetDir" "$downloadUrl" \
    "--header 'Cookie: oraclelicense=accept-securebackup-cookie'"
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
