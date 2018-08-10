source $(dirname "${BASH_SOURCE[0]}")/../utils/import.sh
import utils/print
import utils/tmpdir
import utils/extract
import utils/path
import utils/delimmap

declare -xr GNU_ARCH="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)"
declare -xr NPROC="$(nproc)"

gnuArch() {
  dpkg-architecture --query DEB_BUILD_GNU_TYPE
}

grepLink() {
  local -r url="${1:?Expected url}"
  local -r pattern="${2:?Expected pattern}"
  curl -s "$url" | \
    grep -oE "[hH][rR][eE][fF]=\"${pattern}\"" | \
    cut -f 2 -d \"
}

grepQuotedContent() {
  local -r url="${1:?Expected url}"
  local -r pattern="${2:?Expected pattern}"
  curl -s "$url" | \
    grep -oE "\"${pattern}\"" | \
    cut -f 2 -d \"
}

extractFromUrl() {
  local -r downloadUrl="${1:?Expected download url}"
  local -r targetDir="${2:?Expected target directory}"
  shift; shift
  local -r wgetParams=("$@")
  local -r fileName="${downloadUrl##*/}"
  local -r tmpdir="$(tmpdir_create)"
  cd "$tmpdir"
  printInfo "Downloading $fileName from $downloadUrl"
  printDebug "Using temporary location: $tmpdir"
  wget -q --show-progress --no-check-certificate --no-cookies "${wgetParams[@]}" -O $fileName $downloadUrl
  printTrace "Downloaded $fileName from $downloadUrl to $tmpdir"
  printInfo "Extracting $fileName files to $targetDir"
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
  cd "$sourcesDir"
  printInfo "Building ${downloadUrl##*/}"
  ./configure --prefix="$targetDir" --build="$GNU_ARCH" $configOptions | spin
  make -j "$NPROC" | spin
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
  local -r currentValue="${!name}"
  local -r prevValueName="_SDKVM_PREV_${name}"
  local -r prevValue="${!prevValueName}"
  if [ -n "$prevValue" ]; then
    sdk_eval "export $name=\"$prevValue\""
  else
    sdk_eval "unset $name"
  fi
  sdk_eval "unset $prevValueName"
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

installPackages() {
  local -r packages="${@:?Expected packages}"
  printInfo "Installing additional system packages (password may be required)"
  printDebug "Packages:\n$packages"
  if [ -x "$(command -v apt-get)" ]; then
    sudo apt-get update | spin
    sudo apt-get -y install $packages | spin
  elif [ -x "$(command -v yum)" ]; then
    sudo yum -y install $packages | spin
  else
    error "Could not install packages. Unrecognized package manager."
  fi
  printDebug "Installed packages"
}
