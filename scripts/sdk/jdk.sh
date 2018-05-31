#!/bin/bash -e

source $(dirname "${BASH_SOURCE[0]}")/../utils/install.sh

declare -rgA jdk_versions=(
  ["oracle-jdk-8"]="http://download.oracle.com/otn-pub/java/jdk/8u172-b11/a58eab1ec242421181065cdc37240b08/jdk-8u172-linux-x64.tar.gz"
  ["oracle-jdk-10"]="http://download.oracle.com/otn-pub/java/jdk/10.0.1+10/fb4372174a714e6b8c52526dc134031e/jdk-10.0.1_linux-x64_bin.tar.gz"
)

sdkvm_install() {
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

sdkvm_switch() {
  local -r sdkDir="$1"
  local -r newVersion="$2"
  local -r prevVersion="$3"
  local -r prevJavaHome="$sdkDir/$prevVersion"
  local -r newJavaHome="$sdkDir/$newVersion"
  echo "export JAVA_HOME=\"$newJavaHome\""
  echo "export PATH=\"$(replacePathPart "$prevJavaHome/bin" "$newJavaHome/bin")\""
}

sdkvm_list() {
  echo "${!jdk_versions[@]}" | sed 's| |\n|g'
}
