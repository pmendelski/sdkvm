source "$(dirname "${BASH_SOURCE[0]}")/../utils/import.sh"
import utils/print
import utils/systype
import utils/archtype
import utils/tmpdir
import utils/extract
import utils/path
import utils/delimmap
import utils/ccurl
import utils/error

grepLink() {
  local -r url="${1:?Expected url}"
  local -r pattern="${2:?Expected pattern}"
  ccurl -s --compressed "$url" |
    grep -oE "[hH][rR][eE][fF]=\"${pattern}\"" |
    cut -f 2 -d \"
}

grepQuotedContent() {
  local -r url="${1:?Expected url}"
  local -r pattern="${2:?Expected pattern}"
  ccurl -s --compressed "$url" |
    grep -oE "\"${pattern}\"" |
    cut -f 2 -d \"
}

extractFromUrl() {
  local -r downloadUrl="${1:?Expected download url}"
  local -r targetDir="${2:?Expected target directory}"
  shift
  shift
  local -r wgetParams=("$@")
  local -r tmpdir="$(tmpdir_create)"
  local -r fileName="${downloadUrl##*/}"
  cd "$tmpdir" || error "Dir does not exist $tmpdir"
  printInfo "Downloading $fileName from $downloadUrl"
  printDebug "Using temporary location: $tmpdir"
  if [ ${#wgetParams[@]} -eq 0 ]; then
    wget -q --show-progress --no-check-certificate --no-cookies -O "$fileName" "$downloadUrl"
  else
    wget -q --show-progress --no-check-certificate --no-cookies "${wgetParams[@]}" -O "$fileName" "$downloadUrl"
  fi
  printTrace "Downloaded $fileName from $downloadUrl to $tmpdir"
  printInfo "Extracting $fileName to $targetDir"
  extract "$fileName" "$targetDir"
  printTrace "Extracted $fileName files to $targetDir"
  tmpdir_remove "$tmpdir"
}

buildFromUrl() {
  local -r downloadUrl="${1:?Expected download url}"
  local -r targetDir="${2:?Expected target dir}"
  local -r configOptions="$3"
  local -r sourcesDir="$(tmpdir_create)"
  extractFromUrl "$downloadUrl" "$sourcesDir"
  cd "$sourcesDir" || error "Dir does not exist $sourcesDir"
  printInfo "Building ${downloadUrl##*/}"
  printDebug "Using $(nproc) threads for build"
  printDebug "Config options: $configOptions"
  ./configure --prefix="$targetDir" "$configOptions" | spin
  make -j "$(nproc)" | spin
  make install | spin
  rm -rf "$sourcesDir"
  printDebug "Built ${downloadUrl##*/}"
}

setupVariableWithBackup() {
  local -r name="${1:?Expected name}"
  local -r value="${2:?Expected value}"
  local -r currentValue="${!name}"
  local -r prevValueName="_SDKVM_PREV_${name}"
  if [ -n "$currentValue" ]; then
    if [ "$currentValue" != "$value" ]; then
      sdk_eval "export $prevValueName=\"$currentValue\""
    else
      sdk_eval "export $prevValueName=\"\$$name\""
    fi
  fi
  sdk_eval "export ${name}=\"$value\""
}

restorePreviousValue() {
  local -r name="${1:?Expected name}"
  if [[ -v "$name" ]]; then
    local -r currentValue="${!name}"
    local -r prevValueName="_SDKVM_PREV_${name}"
    local -r prevValue="${!prevValueName}"
    if [ -n "$prevValue" ]; then
      sdk_eval "export $name=\"$prevValue\""
    else
      sdk_eval "unset $name"
    fi
    sdk_eval "unset $prevValueName"
  fi
}

addToPath() {
  local -r dir="${1:?Expected dir}"
  sdk_eval "export PATH=\"$dir:\$PATH\""
}

removeFromPath() {
  local -r dir="${1:?Expected dir}"
  sdk_eval "export PATH=\"$(path_remove "$dir")\""
}

setupHomeAndPath() {
  local -r name="${1:?Expected name}"
  local -r sdkDir="${2:?Expected sdk directory}"
  local -r sdkBinDir="${3:-$sdkDir/bin}"
  setupVariableWithBackup "${name}_HOME" "$sdkDir"
  sdk_eval "export PATH=\"$sdkBinDir:\$PATH\""
}

resetHomeAndPath() {
  local -r name="${1:?Expected name}"
  local -r sdkDir="${2:?Expected sdk directory}"
  local -r sdkBinDir="${3:-$sdkDir/bin}"
  restorePreviousValue "${name}_HOME"
  sdk_eval "export PATH=\"$(path_remove "$sdkBinDir")\""
}

installLinuxPackages() {
  if ! isLinux; then
    return
  fi
  local -r packages="${*:?Expected packages}"
  printInfo "Installing additional system packages (password may be required)"
  printDebug "Packages:\n$packages"
  if [ -x "$(command -v apt-get)" ]; then
    sudo apt-get update | spin
    sudo apt-get -y install "$packages" | spin
  elif [ -x "$(command -v yum)" ]; then
    sudo yum -y install "$packages" | spin
  else
    error "Could not install packages. Unrecognized package manager."
  fi
  printDebug "Installed packages"
}

ubuntuDesktopEntry() {
  if ! isUbuntu; then
    return
  fi
  local -r name="$1"
  local -r dir="$HOME/.local/share/applications"
  local entries=""
  shift
  for i in "$@"; do
    entries="$entries$i\n"
  done
  if [ -d "$dir" ]; then
    if [ -f "$dir/$name.desktop" ] && [ "$entries\n" == "$(cat "$dir/$name.desktop")" ]; then
      return
    fi
    if [ -f "$dir/$name.desktop" ] && [ ! -f "$dir/$name.desktop.bak" ]; then
      mv "$dir/$name.desktop" "$dir/$name.desktop.bak"
    fi
    printInfo "Creating desktop entry: $dir/$name.desktop"
    echo -e "$entries" >"$dir/$name.desktop"
    updateDesktopEntries
  fi
}

resetDesktopEntry() {
  if ! isUbuntu; then
    return
  fi
  local -r name="$1"
  local -r dir="$HOME/.local/share/applications"
  if [ -f "$dir/$name.desktop.bak" ]; then
    printInfo "Restoring desktop entry: $dir/$name.desktop"
    mv "$dir/$name.desktop.bak" "$dir/$name.desktop"
    updateDesktopEntries
  fi
}

updateDesktopEntries() {
  if ! isUbuntu; then
    return
  fi
  if [ -x "$(command -v update-desktop-database)" ]; then
    printInfo "Updating desktop entries"
    sudo update-desktop-database || printWarn "Could not update desktop entries"
  fi
}
