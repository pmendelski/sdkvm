#!/bin/bash -e

source $(dirname "${BASH_SOURCE[0]}")/_base.sh

pythonDownloadUrls() {
  curl -s https://www.python.org/downloads/source/ | \
    grep -oE 'href="https://www.python.org/ftp/python/[0-9.]+/[Pp]ython-[0-9.]+.tgz"' | \
    cut -f 2 -d \"
}

pythonDownloadUrl() {
  local -r version="${1?Expected version}"
  local -r versionNumber="${version#python-}"
  pythonDownloadUrls | \
    grep "Python-$versionNumber.tgz" | \
    head -n 1
}

_sdkvm_versions() {
  pythonDownloadUrls | \
    grep -oE 'Python-[0-9.]*[0-9]+' |
    sed 's|Python-|python-|' |
    sort -urV
}

_sdkvm_install() {
  local -r version="$1"
  local -r sourcesDir="$2-src"
  local -r targetDir="$2"
  local -r downloadUrl="$(pythonDownloadUrl "$version")"
  installFromUrl "python" "$version" "$sourcesDir" "$downloadUrl"
  installPackages build-essential \
    libsqlite3-dev sqlite3 \
    bzip2 libbz2-dev zlib1g-dev \
    libssl-dev openssl \
    libgdbm-dev libgdbm-compat-dev \
    liblzma-dev libreadline-dev libncursesw5-dev libffi-dev uuid-dev
  cd "$sourcesDir"
  ./configure --prefix="$targetDir"
  make
  make install
  rm -rf "$sourcesDir"
  if [ -f "$targetDir/bin/python3" ]; then
    printInfo "Recognized python3. Linking as python."
    ln -f "$targetDir/bin/python3" "$targetDir/bin/python"
    ln -f "$targetDir/share/man/man1/python3.1" "$targetDir/share/man/man1/python.1"
  fi
  pip install --upgrade pip
}

_sdkvm_enable() {
  setupHomeAndPath "PYTHON" "$2"
}

_sdkvm_disable() {
  resetHomeAndPath "PYTHON" "$2"
}
