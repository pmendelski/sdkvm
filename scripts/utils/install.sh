source $(dirname "${BASH_SOURCE[0]}")/print.sh
source $(dirname "${BASH_SOURCE[0]}")/tmpdir.sh

package() {
  local -r name="$1"
  local -r installFile="${BASH_SOURCE[1]}"
  (sudo apt install -y $name && printSuccess "Package installed successfully: $name ($installFile)") \
    || error "Could not install package: $name ($installFile)"
}

download() {
  local -r url="$1"
  local -r target="$2"
  if [ -z "$target" ]; then
    wget -q --show-progress "$url" || error "Could not download $url"
  elif [[ "$target" == /tmp/* ]]; then
    wget -q --show-progress "$url" -O "$target" || error "Could not download $url"
  else
    sudo wget -q --show-progress "$url" -O "$target" || error "Could not download $url"
  fi
}

extract() {
  local -r package="$1"
  local -r dest="${2:-${package%%.*}}"
  local -r tmp="$(mktemp -d)"
  printDebug "Extracting ${package}"
  case "$package" in
    *.tar.gz|*.tgz) tar zxf "$package" -C "${tmp}" ;;
    *.zip) unzip -q "$package" -d "${tmp}" ;;
    *) error "Could not extract $package";;
  esac
  local -r extracted="$(ls -1q "$tmp")"
  if [[ ! ${#extracted[*]} == "1" ]]; then
    error "Expected package ${package} to contain single directory. Got: ${#extracted[*]}"
  fi
  if [[ ! -d "${tmp}/${extracted}" ]]; then
    error "Expected package ${package} to contain a directory. ${tmp}/${extracted} is not a directory."
  fi
  mkdir -p "$dest"
  mv "${tmp}/${extracted}"/* "$dest"
  rm -rf "$tmp"
}

replacePathPart() {
  local -r path="$1"
  local -r replacement="$2"
  echo ":${PATH}:" \
    | sed "s|:$path:|:|" \
    | sed "s|^:|$replacement:|"
    | sed 's|:*$||'
}
