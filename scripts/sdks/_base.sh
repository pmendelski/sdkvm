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
