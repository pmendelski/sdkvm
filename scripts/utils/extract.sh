extract() {
  local -r package="$1"
  local -r dest="${2:-${package%%.*}}"
  local -r tmp="$(mktemp -d)"
  printDebug "Extracting ${package}"
  case "$package" in
  *.tar.gz | *.tgz) tar zxf "$package" -C "${tmp}" ;;
  *.zip) unzip -q "$package" -d "${tmp}" ;;
  *) error "Could not extract $package" ;;
  esac
  local -r extracted="$(ls -1q "$tmp")"
  if [[ ! ${#extracted[*]} == "1" ]]; then
    error "Expected package ${package} to contain single directory. Got: ${#extracted[*]}"
  fi
  if [[ -f "${tmp}/${extracted}" ]]; then
    mkdir -p "${tmp}/${extracted}-dir"
    mv "${tmp}/${extracted}" "${tmp}/${extracted}-dir"
    mv "${tmp}/${extracted}-dir" "${tmp}/${extracted}"
  fi
  if [[ ! -d "${tmp}/${extracted}" ]]; then
    error "Expected package ${package} to contain a directory. ${tmp}/${extracted} is not a directory."
  fi
  mkdir -p "$dest"
  mv "${tmp}/${extracted}"/* "$dest"
  rm -rf "$tmp"
}
