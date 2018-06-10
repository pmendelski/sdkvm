# This script should be sourced only once
[[ ${__UTILS_IMPORT_SOURCED:-} -eq 1 ]] && return || readonly __UTILS_IMPORT_SOURCED=1

declare -rg __IMPORT_BASEDIR="$(dirname "${BASH_SOURCE[0]}")/.."
declare -rg __IMPORT_FILEPATH="${BASH_SOURCE[0]}"
declare -g __IMPORTED=()

import() {
  import_error() {
    (>&2 echo $1)
    exit 1
  }

  local -r callerFile="$(caller 0 | sed -E 's|[0-9]+ +[^ ]+ +||')"
  local -r callerDir="$(dirname "$callerFile")"
  local -r path="$([ "$1" = "${1#./}" ] && echo "$__IMPORT_BASEDIR/$1" || echo "$callerDir/${1#./}")"
  local -r file="$([ -d "$path" ] && echo "$path/index.sh" || echo "${path%.sh}.sh")"
  local -r resolved="$(readlink -f "$file")"
  [ -f "$file" ] || import_error "Could not import \"${file}\" from \"$callerFile\". File does not exist."
  [ "$resolved" == "$__IMPORT_FILEPATH" ] && import_error "Could not import the import script \"$resolved\" from \"$callerFile\"."

  local cached=0
  for imported in "${__IMPORTED[@]}"; do
    if [ "$imported" = "$resolved" ]; then
      cached=1
      break
    fi
  done

  if [ $cached = 0 ]; then
    __IMPORTED+=("$resolved")
    source "$resolved" \
      || import_error "Could not import \"${resolved}\" from \"$callerFile\". Could not source it."
  fi
}
