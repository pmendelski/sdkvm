#!/bin/bash -e

source $(dirname "${BASH_SOURCE[0]}")/_base.sh

ideaDownloadUrls() {
  local -r name="${1:?Expected name}"
  curl -s "https://data.services.jetbrains.com/products?code=IIU%2CIIC&release.type=release" | \
    grep -oP "https://download.jetbrains.com/idea/$name-[0-9]*\.[0-9]*\.[0-9]*\.tar\.gz" | \
    sort -ru
}

ideaDownloadUrl() {
  local -r name="${1:?Expected name}"
  local -r version="${2:?Expected version}"
  ideaDownloadUrls "$name" | \
    grep "/$name-$version" | \
    head -n 1
}

ideaVersions() {
  local -r name="${1:?Expected name}"
  ideaDownloadUrls "$name" | \
    grep -oE "$name-[^-_]+" | \
    sed "s|^$name-||" | \
    sed 's|.tar.gz$||'
}

ideaInstall() {
  local -r name="${1:?Expected name}"
  local -r binName="${2:?Expected name}"
  local -r version="$3"
  local -r targetDir="$4"
  extractFromUrl "$(ideaDownloadUrl "$name" "$version")" "$targetDir"
  ln -sf "$targetDir/bin/idea.sh" "$targetDir/bin/$binName"
}

ideaEnable() {
  local -r name="${1:?Expected name}"
  local -r homeName="$2"
  local -r home="$3"
  desktopEntry "$name" \
    "[Desktop Entry]" \
    "Type=Application" \
    "Encoding=UTF-8" \
    "Name=IntelliJ - $name" \
    "Icon=$home/bin/idea.png" \
    "Comment=IntelliJ Idea - $name" \
    "Exec=$home/bin/idea.sh" \
    "Terminal=false" \
    "Categories=IDE;"
  setupHomeAndPath "$homeName" "$home"
}

ideaDisable() {
  local -r name="${1:?Expected name}"
  local -r homeName="$2"
  local -r home="$3"
  resetDesktopEntry "$name"
  resetHomeAndPath "$homeName" "$home"
}

_sdkvm_versions() {
  ideaVersions "ideaIC"
}

_sdkvm_install() {
  ideaInstall "ideaIC" "idea-ic" "$1" "$2"
}

_sdkvm_enable() {
  ideaEnable "ideaIC" "IDEA_IC" "$2"
}

_sdkvm_disable() {
  ideaDisable "ideaIC" "IDEA_IC" "$2"
}

