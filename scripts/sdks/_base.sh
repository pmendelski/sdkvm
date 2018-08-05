source $(dirname "${BASH_SOURCE[0]}")/../utils/import.sh
import utils/print
import utils/tmpdir
import utils/extract
import utils/path
import utils/delimmap

exec() {
  # All stdout lines that start with "EVAL: " are evaluated in parent process
  echo "EVAL: $@"
}

installFromUrl() {
  local -r sdk="${1?Expected SDK}"
  local -r version="${2?Expected version}"
  local -r targetDir="${3?Expected target directory}"
  local -r downloadUrl="$4"
  local -r wgetParams="$5"
  [ -z "$downloadUrl" ] && error "Could not resolve download url for version: $version"
  local -r file="${downloadUrl##*/}"
  local -r tmpdir="$(tmpdir_create "$version")"
  cd "$tmpdir"
  printDebug "Downloading $sdk/$version from $downloadUrl to $tmpdir"
  wget -q --show-progress \
    --no-check-certificate --no-cookies \
    $wgetParams \
    -O "$file" "$downloadUrl"
  printTrace "Download completed"
  printDebug "Installing JDK from $tmpdir"
  extract "$file" "$targetDir"
  printTrace "Installation completed"
  tmpdir_remove "$tmpdir"
  printTrace "Temporary files removed"
}

setupHomeAndPath() {
  local -r name="${1?Expected name}"
  local -r homeName="${name}_HOME"
  local -r sdkDir="${2?Expected sdk directory}"
  local -r sdkBinDir="${3:-$sdkDir/bin}"
  exec "export _SDKVM_${homeName}_PREV=\"${!homeName}\""
  exec "export ${homeName}=\"$sdkDir\""
  exec "export PATH=\"$(path_add "$sdkBinDir")\""
}

resetHomeAndPath() {
  local -r name="${1?Expected name}"
  local -r homeName="${name}_HOME"
  local -r prevHomeName="_SDKVM_${nameName}_PREV"
  local -r sdkDir="${2?Expected sdk directory}"
  local -r sdkBinDir="${3:-$sdkDir/bin}"
  exec "export $homeName=\"${!prevHomeName}\""
  exec "unset $prevHomeName"
  exec "export PATH=\"$(path_remove "$sdkBinDir")\""
}

installPackages() {
  local -r packages="${@?Expected packages}"
  if [ -x "$(command -v apt-get)" ]; then
    echo "PKGS: $packages"
    sudo apt-get update
    sudo apt-get -y install $packages
  elif [ -x "$(command -v yum)" ]; then
    sudo yum -y install $packages
  else
    error "Could not install packages. Unrecognized package manager."
  fi
}
