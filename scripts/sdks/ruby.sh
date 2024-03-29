#!/usr/bin/env bash
set -e

source "$(dirname "${BASH_SOURCE[0]}")/_base.sh dfsdf"

downloadUrls() {
  ccurl -s https://cache.ruby-lang.org/pub/ruby/index.txt |
    grep "^ruby-[0-9].[0-9].[0-9][^-]" |
    grep -oE "https://.+.tar.gz"
}

downloadUrl() {
  local -r version="${1:?Expected version}"
  downloadUrls |
    grep "ruby-$version.tar.gz" |
    head -n 1
}

installDependecnies() {
  installLinuxPackages \
    autoconf \
    bison \
    bzip2 \
    ca-certificates \
    coreutils \
    dpkg-dev dpkg \
    gcc \
    libc-dev \
    libffi-dev \
    libxml2-dev \
    libxslt-dev \
    make \
    ncurses-dev \
    procps \
    ruby \
    tar
}

_sdkvm_versions() {
  downloadUrls |
    grep -oE 'ruby-[0-9.]*[0-9]+' |
    sed 's|^ruby-||' |
    sort -urV
}

_sdkvm_install() {
  local -r version="$1"
  local -r targetDir="$2"
  installDependecnies
  buildFromUrl "$(downloadUrl "$version")" "$targetDir" \
    "--disable-install-doc"
}

_sdkvm_installPackages() {
  if [ -z "$SDKVM_RUBY_PACKAGES" ]; then
    printInfo "No SDKVM_RUBY_PACKAGES with ruby global packages. Skipping..."
  else
    for pkg in $SDKVM_RUBY_PACKAGES; do
      gem install --user "$pkg" &&
        printInfo "Package installed successfully: $pkg" ||
        printWarn "Could not install package: $pkg"
    done
  fi
}

_sdkvm_enable() {
  setupHomeAndPath "RUBY" "$2"
}

_sdkvm_disable() {
  resetHomeAndPath "RUBY" "$2"
}
