# This script should be sourced only once
[[ ${UTILS_DELIMLIST:-} -eq 1 ]] && return || readonly UTILS_DELIMLIST=1

declare -r VALLUE_DELIM_REPLACEMENT="%COLON%"

delimlist_encodeValue() {
  local -r delim="${2:-:}"
  echo "${1//$delim/$VALLUE_DELIM_REPLACEMENT}"
}

delimlist_decodeValue() {
  local -r delim="${2:-:}"
  echo "${1//$VALLUE_DELIM_REPLACEMENT/$delim}"
}

delimlist_contains() {
  local -r delim="${3:-:}"
  local -r text="${delim}${1}${delim}"
  local -r tocheck="$(delimlist_encodeValue "$2" "$delim")"
  [ "$text" != "${text//${delim}${tocheck}${delim}/}" ]
}

delimlist_remove() {
  local -r text="$1"
  local -r delim="${3:-:}"
  local -r toremove="$(delimlist_encodeValue "$2" "$delim")"
  if [ "$text" = "$toremove" ]; then
    echo ""
  else
    echo "${delim}${text}${delim}" \
      | sed "s|${delim}${toremove}${delim}|${delim}|" \
      | sed -E "s|${delim}(.*)${delim}|\1|"
  fi
}

delimlist_add() {
  local -r text="$1"
  local -r toadd="$2"
  local -r delim="${3:-:}"
  if [ -z "$text" ]; then
    delimlist_encodeValue "$toadd" "$delim"
  else
    delimlist_contains "$text" "$toadd" "$delim" \
      && echo "$text" \
      || echo "${text}${delim}$(delimlist_encodeValue "$toadd" "$delim")"
  fi
}

delimlist_addAsFirst() {
  local -r text="$(delimlist_remove "$1" "$2" "$delim")"
  local -r delim="${3:-:}"
  local -r toadd="$2"
  echo "$(delimlist_encodeValue "$toadd" "$delim")${delim}${text}"
}

delimlist_replace() {
  local -r text="$1"
  local -r delim="${4:-:}"
  local -r toreplace="$(delimlist_encodeValue "$2" "$delim")"
  local -r replacement="$(delimlist_encodeValue "$3" "$delim")"
  echo "${delim}${text}${delim}" \
    | sed "s|${delim}${toreplace}${delim}|${delim}${replacement}${delim}|" \
    | sed -E "s|${delim}(.*)${delim}|\1|"
}

delimlist_values() {
  local -r text="$1"
  local -r delim="${2:-:}"
  local -r encoded="$(echo "$text" | sed "s|${delim}|\n|g")"
  for v in "$encoded"; do
    delimlist_decodeValue "$v" "$delim"
  done
}

delimlist_first() {
  local -r text="$1"
  local -r delim="${2:-:}"
  delimlist_values "$text" "$delim" | head -n 1
}

delimlist_removeFirst() {
  local -r text="$1"
  local -r delim="${2:-:}"
  local -r first="$(delimlist_first "$text" "$delim")"
  if [ -n "$first" ]; then
    delimlist_remove "$text" "$delim" "$first"
  fi
}

delimlist_findByPrefix() {
  local -r text="$1"
  local -r prefix="$2"
  local -r delim="${3:-:}"
  echo "$(delimlist_values "$text" "$delim")" | grep "$prefix"
}

delimlist_findFirstByPrefix() {
  delimlist_findByPrefix $@ | head -n 1
}
