#!/bin/bash -e

source $(dirname "${BASH_SOURCE[0]}")/_base.sh

_sdkvm_versions() {
  echo "jdk-10 http://download.oracle.com/otn/java/jdk/10+46/76eac37278c24557a3c4199677f19b62/jdk-10_linux-x64_bin.tar.gz"
  echo "jdk-9  http://download.oracle.com/otn/java/jdk/9.0.4+11/c2514751926b4512b076cc82f959763f/jdk-9.0.4_linux-x64_bin.tar.gz"
  echo "jdk-8  http://download.oracle.com/otn/java/jdk/8u162-b12/0da788060d494f5095bf8624735fa2f1/jdk-8u162-linux-x64.tar.gz"
}

_sdkvm_install() {
  local -r version="$1"
  local -r targetDir="$2"
  local -r downloadUrl="$3"
  local -r file="${downloadUrl##*/}"
  local -r tmpdir="$(tmpdir_create "$version")"
  cd "$tmpdir"
  printDebug "Downloading JDK from $downloadUrl to $tmpdir"
  wget -q --show-progress \
    --no-check-certificate --no-cookies \
    --header "Cookie: oraclelicense=accept-securebackup-cookie" \
    -O "$file" "$downloadUrl"
  printDebug "Installing JDK from $tmpdir"
  extract "$file" "$targetDir"
  tmpdir_remove "$tmpdir"
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
