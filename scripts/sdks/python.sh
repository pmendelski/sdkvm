#!/bin/bash -e

source $(dirname "${BASH_SOURCE[0]}")/_base.sh

downloadUrls() {
  grepLink \
    'https://www.python.org/downloads/source/' \
    'https://www.python.org/ftp/python/[0-9.]+/[Pp]ython-[0-9.]+.tgz'
}

downloadUrl() {
  local -r version="${1:?Expected version}"
  downloadUrls | \
    grep "Python-$version.tgz" | \
    head -n 1
}

postInstall() {
  local -r sdkDir="${1:?Expected target dir}"
  if [ -f "$targetDir/bin/python3" ]; then
    printInfo "Recognized python3. Linking as python."
    ln -s "$targetDir/bin/idle3" "$targetDir/bin/idle"
    ln -s "$targetDir/bin/pip3" "$targetDir/bin/pip"
    ln -s "$targetDir/bin/python3" "$targetDir/bin/python"
    ln -s "$targetDir/bin/pydoc3" "$targetDir/bin/pydoc"
    ln -s "$targetDir/bin/python3-config" "$targetDir/bin/python-config"
    ln -s "$targetDir/share/man/man1/python3.1" "$targetDir/share/man/man1/python.1"
  fi
}

installDependecnies() {	
  installLinuxPackages \	
    build-essential \	
    libsqlite3-dev sqlite3 \	
    bzip2 libbz2-dev zlib1g-dev \	
    libssl-dev openssl \	
    libgdbm-dev libgdbm-compat-dev \	
    liblzma-dev libreadline-dev libncursesw5-dev libffi-dev uuid-dev	
}

_sdkvm_versions() {
  downloadUrls | \
    grep -oE 'Python-[0-9.]*[0-9]+' |
    sed 's|^Python-||' |
    sort -urV
}

_sdkvm_install() {
  local -r version="$1"
  local -r targetDir="$2"
  installDependecnies
  buildFromUrl "$(downloadUrl "$version")" "$targetDir"
  postInstall "$targetDir"
}

_sdkvm_enable() {
  setupHomeAndPath "PYTHON" "$2"
}

_sdkvm_disable() {
  resetHomeAndPath "PYTHON" "$2"
}
