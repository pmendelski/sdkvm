#!/bin/bash -e

source $(dirname "${BASH_SOURCE[0]}")/_base.sh

declare -rgA jdk_versions=(
  ["oracle-jdk-8"]="http://download.oracle.com/otn-pub/java/jdk/8u172-b11/a58eab1ec242421181065cdc37240b08/jdk-8u172-linux-x64.tar.gz"
  ["oracle-jdk-10"]="http://download.oracle.com/otn-pub/java/jdk/10.0.1+10/fb4372174a714e6b8c52526dc134031e/jdk-10.0.1_linux-x64_bin.tar.gz"
)

_sdkvm_install() {
  local -r version="$1"
  local -r targetDir="$2"
  local -r downloadUrl="${jdk_versions[$version]}"
  [ -z "$downloadUrl" ] && error "Could not find JDK version: \"$version\""
  printInfo "Installing JDK: $version"
  local -r file="${downloadUrl##*/}"
  local -r tmpdir="$(createTmpDir "$version")"
  cd "$tmpdir"
  printDebug "Downloading JDK from $downloadUrl to $tmpdir"
  wget -q --show-progress \
    --no-check-certificate --no-cookies \
    --header "Cookie: oraclelicense=accept-securebackup-cookie" \
    -O "$file" "$downloadUrl"
  printDebug "Installing JDK from $tmpdir"
  extract "$file" "$targetDir"
  removeTmpDir "$tmpdir"
}

_sdkvm_enable() {
  local -r sdkDir="$2"
  echo "EVAL: export _SDKVM_JAVA_HOME_PREV=\"$JAVA_HOME\""
  echo "EVAL: export JAVA_HOME=\"$sdkDir\""
  echo "EVAL: export PATH=\"$sdkDir/bin:$PATH\""
}

_sdkvm_disable() {
  local -r sdkDir="$2"
  local -r javaHome="$sdkDir"
  echo "EVAL: export JAVA_HOME=\"$_SDKVM_JAVA_HOME_PREV\""
  echo "EVAL: unset _SDKVM_JAVA_HOME_PREV"
  echo "EVAL: export PATH=\"$(removeFromPath "$javaHome/bin")\""
}

_sdkvm_versions() {
  echo "${!jdk_versions[@]}" | sed 's| |\n|g'
}
