source $(dirname "${BASH_SOURCE[0]}")/../utils/import.sh
import utils/print
import utils/tmpdir
import utils/extract
import utils/path
import utils/delimmap

declare -gr GNU_ARCH="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)"
declare -gr NPROC="$(nproc)"

gnuArch() {
  dpkg-architecture --query DEB_BUILD_GNU_TYPE
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

setupHomeAndPath() {
  local -r name="${1:?Expected name}"
  local -r homeName="${name}_HOME"
  local -r sdkDir="${2:?Expected sdk directory}"
  local -r sdkBinDir="${3:-$sdkDir/bin}"
  sdk_eval "export _SDKVM_${homeName}_PREV=\"${!homeName}\""
  sdk_eval "export ${homeName}=\"$sdkDir\""
  sdk_eval "export PATH=\"$(path_add "$sdkBinDir")\""
}

resetHomeAndPath() {
  local -r name="${1:?Expected name}"
  local -r homeName="${name}_HOME"
  local -r prevHomeName="_SDKVM_${nameName}_PREV"
  local -r sdkDir="${2:?Expected sdk directory}"
  local -r sdkBinDir="${3:-$sdkDir/bin}"
  sdk_eval "export $homeName=\"${!prevHomeName}\""
  sdk_eval "unset $prevHomeName"
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
