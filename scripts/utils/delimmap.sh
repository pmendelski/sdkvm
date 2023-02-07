# This script should be sourced only once
[[ ${UTILS_DELIMMAP:-} -eq 1 ]] && return || readonly UTILS_DELIMMAP=1

source "$(dirname "${BASH_SOURCE[0]}")/delimlist.sh"

declare -r ENTRY_DELIM_REPLACEMENT="%SLASH%"

delimmap_encodeEntry() {
  local -r delim="${2:-/}"
  echo "${1//$delim/$ENTRY_DELIM_REPLACEMENT}"
}

delimmap_decodeEntry() {
  local -r delim="${2:-/}"
  echo "${1//$ENTRY_DELIM_REPLACEMENT/$delim}"
}

delimmap_keys() {
  local -r text="$1"
  local -r delim="${2:-:}"
  local -r slash="${3:-/}"
  local -r key="$2$slash"
  local -r entry="$(delimlist_findFirstByPrefix "$text" "$key" "$delim")"
  echo "${entry#$key}"
}

delimmap_get() {
  local -r text="$1"
  local -r delim="${3:-:}"
  local -r slash="${4:-/}"
  local -r key="$(delimmap_encodeEntry "$2" "$slash")${slash}"
  local -r entry="$(delimlist_findFirstByPrefix "$text" "$key" "$delim")"
  delimmap_decodeEntry "${entry#$key}"
}

delimmap_remove() {
  local -r text="$1"
  local -r delim="${4:-:}"
  local -r slash="${5:-/}"
  local -r key="$(delimmap_encodeEntry "$2" "$slash")"
  local -r value="$(delimmap_encodeEntry "$3" "$slash")"
  local -r entries="$(delimlist_findByPrefix "$text" "${key}${slash}${value}" "$delim")"
  local result="$text"
  for entry in $entries; do
    result="$(delimlist_remove "$result" "$entry" "$delim")"
  done
  echo "$result"
}

delimmap_put() {
  local -r text="$1"
  local -r delim="${4:-:}"
  local -r slash="${5:-/}"
  local -r key="$(delimmap_encodeEntry "$2" "$slash")"
  local -r value="$(delimmap_encodeEntry "$3" "$slash")"
  delimlist_add "$(delimmap_remove "$text" "$key" "" "$delim" "$slash")" "${key}${slash}${value}" "$delim"
}

delimmap_contains() {
  local -r text="$1"
  local -r delim="${4:-:}"
  local -r slash="${5:-/}"
  local -r key="$(delimmap_encodeEntry "$2" "$slash")"
  local -r value="$(delimmap_encodeEntry "$3" "$slash")"
  if [ -z "$value" ]; then
    [ -n "$(delimmap_get "$text" "$key" "$delim" "$slash")" ]
  else
    delimlist_contains "$text" "$key$slash$value" "$delim"
  fi
}

delimmap_keys() {
  local -r text="$1"
  local -r delim="${2:-:}"
  local -r slash="${3:-/}"
  local -r entries="$(delimlist_values "$text" "${key}${slash}${value}" "$delim")"
  local result=""
  for entry in $entries; do
    result="$result${delim}${entry//${slash}*/}"
  done
  echo "$result"
}
