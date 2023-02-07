#!/usr/bin/env bash
set -e

source "$(dirname "${BASH_SOURCE[0]}")/_base.sh"

downloadUrls() {
  grepLink \
    'https://www.python.org/downloads/source/' \
    'https://www.python.org/ftp/python/[0-9.]+/[Pp]ython-[0-9.]+.tgz'
}

downloadUrl() {
  local -r version="${1:?Expected version}"
  downloadUrls |
    grep "Python-$version.tgz" |
    head -n 1
}

postInstall() {
  sleep 3 # wait for all I/O
  local -r targetDir="${1:?Expected target dir}"
  if [ -f "$targetDir/bin/python3" ]; then
    printInfo "Recognized python3. Linking as python."
    ln -s "$targetDir/bin/idle3" "$targetDir/bin/idle"
    ln -s "$targetDir/bin/pip3" "$targetDir/bin/pip"
    ln -s "$targetDir/bin/python3" "$targetDir/bin/python"
    ln -s "$targetDir/bin/pydoc3" "$targetDir/bin/pydoc"
    ln -s "$targetDir/bin/python3-config" "$targetDir/bin/python-config"
    ln -s "$targetDir/share/man/man1/python3.1" "$targetDir/share/man/man1/python.1"
  fi
  printInfo "Installing pip"
  local -r getPipDir="$(tmpdir_create)"
  cd "$getPipDir"
  curl -s https://bootstrap.pypa.io/get-pip.py -o "get-pip.py"
  "$targetDir/bin/python" "get-pip.py"
  rm -rf "$getPipDir"
}

installDependecnies() {
  installLinuxPackages \
    build-essential \
    libsqlite3-dev sqlite3 \
    bzip2 libbz2-dev zlib1g-dev \
    libssl-dev openssl \
    libgdbm-dev libgdbm-compat-dev \
    liblzma-dev libreadline-dev libncursesw5-dev libffi-dev uuid-dev \
    libxext-dev
  if isMacosWithBrew; then
    brew install readline openssl xz zlib
    local -r opensslPrefix="$(brew --prefix openssl)"
    export PATH="$opensslPrefix/bin:$PATH"
    export LDFLAGS="-L$opensslPrefix/lib"
    export CFLAGS="-I$opensslPrefix/include"
    export CPPFLAGS="-I$opensslPrefix/include"
    export PKG_CONFIG_PATH="$opensslPrefix/lib/pkgconfig"
    export CONFIGURE_OPTS="--with-openssl=$opensslPrefix"
  fi
}

_sdkvm_versions() {
  downloadUrls |
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

_sdkvm_installPackages() {
  if [ -z "$SDKVM_PYTHON_PACKAGES" ]; then
    printInfo "No SDKVM_PYTHON_PACKAGES with python global packages. Skipping..."
  else
    for pkg in $SDKVM_PYTHON_PACKAGES; do
      pip install --user "$pkg" &&
        printInfo "Package installed successfully: $pkg" ||
        printWarn "Could not install package: $pkg"
    done
  fi
}

_sdkvm_enable() {
  setupHomeAndPath "PYTHON" "$2"
}

_sdkvm_disable() {
  resetHomeAndPath "PYTHON" "$2"
}
