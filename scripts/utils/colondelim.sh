declare -r VALLUE_DELIM_REPLACEMENT="%COLON%"
declare -r ENTRY_DELIM_REPLACEMENT="%SLASH%"

colondelim_encodeValueDelim() {
  local -r delim="${2:-:}"
  echo "${1//$delim/$VALLUE_DELIM_REPLACEMENT}"
}

colondelim_decodeValueDelim() {
  local -r delim="${2:-:}"
  echo "${1//$VALLUE_DELIM_REPLACEMENT/$delim}"
}

colondelim_encodeEntryDelim() {
  local -r delim="${2:-/}"
  echo "${1//$delim/$ENTRY_DELIM_REPLACEMENT}"
}

colondelim_decodeEntryDelim() {
  local -r delim="${2:-/}"
  echo "${1//$ENTRY_DELIM_REPLACEMENT/$delim}"
}

colondelim_contains() {
  local -r delim="${3:-:}"
  local -r text="${delim}${1}${delim}"
  local -r tocheck="$(colondelim_encodeValueDelim "$2" "$delim")"
  [ "$text" != "${text//${delim}${tocheck}${delim}/}" ]
}

colondelim_remove() {
  local -r text="$1"
  local -r delim="${3:-:}"
  local -r toremove="$(colondelim_encodeValueDelim "$2" "$delim")"
  if [ "$text" = "$toremove" ]; then
    echo ""
  else
    echo "${delim}${text}${delim}" \
      | sed "s|${delim}${toremove}${delim}|${delim}|" \
      | sed -E "s|${delim}(.*)${delim}|\1|"
  fi
}

colondelim_add() {
  local -r text="$1"
  local -r toadd="$2"
  local -r delim="${3:-:}"
  if [ -z "$text" ]; then
    colondelim_encodeValueDelim "$toadd" "$delim"
  else
    colondelim_contains "$text" "$toadd" "$delim" \
      && echo "$text" \
      || echo "${text}${delim}$(colondelim_encodeValueDelim "$toadd" "$delim")"
  fi
}

colondelim_addAsFirst() {
  local -r text="$(colondelim_remove "$1" "$2" "$delim")"
  local -r delim="${3:-:}"
  local -r toadd="$2"
  echo "$(colondelim_encodeValueDelim "$toadd" "$delim")${delim}${text}"
}

colondelim_replace() {
  local -r text="$1"
  local -r delim="${4:-:}"
  local -r toreplace="$(colondelim_encodeValueDelim "$2" "$delim")"
  local -r replacement="$(colondelim_encodeValueDelim "$3" "$delim")"
  echo "${delim}${text}${delim}" \
    | sed "s|${delim}${toreplace}${delim}|${delim}${replacement}${delim}|" \
    | sed -E "s|${delim}(.*)${delim}|\1|"
}

colondelim_values() {
  local -r text="$1"
  local -r delim="${2:-:}"
  local -r encoded="$(echo "$text" | sed "s|${delim}|\n|g")"
  for v in "$encoded"; do
    colondelim_decodeValueDelim "$v" "$delim"
  done
}

colondelim_findByPrefix() {
  local -r text="$1"
  local -r prefix="$2"
  local -r delim="${3:-:}"
  echo "$(colondelim_values "$text" "$delim")" | grep "$prefix"
}

colondelim_findFirstByPrefix() {
  colondelim_findByPrefix $@ | head -n 1
}

colondelim_mapKeys() {
  local -r text="$1"
  local -r delim="${2:-:}"
  local -r slash="${3:-/}"
  local -r key="$2$slash"
  local -r entry="$(colondelim_findFirstByPrefix "$text" "$key" "$delim")"
  echo "${entry#$key}"
}

colondelim_mapGet() {
  local -r text="$1"
  local -r delim="${3:-:}"
  local -r slash="${4:-/}"
  local -r key="$(colondelim_encodeEntryDelim "$2" "$slash")${slash}"
  local -r entry="$(colondelim_findFirstByPrefix "$text" "$key" "$delim")"
  colondelim_decodeEntryDelim "${entry#$key}"
}

colondelim_mapRemove() {
  local -r text="$1"
  local -r delim="${4:-:}"
  local -r slash="${5:-/}"
  local -r key="$(colondelim_encodeEntryDelim "$2" "$slash")"
  local -r value="$(colondelim_encodeEntryDelim "$3" "$slash")"
  local -r entries="$(colondelim_findByPrefix "$text" "${key}${slash}${value}" "$delim")"
  local result="$text"
  for entry in $entries; do
    result="$(colondelim_remove "$result" "$entry" "$delim")"
  done
  echo "$result"
}

colondelim_mapPut() {
  local -r text="$1"
  local -r delim="${4:-:}"
  local -r slash="${5:-/}"
  local -r key="$(colondelim_encodeEntryDelim "$2" "$slash")"
  local -r value="$(colondelim_encodeEntryDelim "$3" "$slash")"
  colondelim_add "$(colondelim_mapRemove "$text" "$key" "" "$delim" "$slash")" "${key}${slash}${value}" "$delim"
}

colondelim_mapContains() {
  local -r text="$1"
  local -r delim="${4:-:}"
  local -r slash="${5:-/}"
  local -r key="$(colondelim_encodeEntryDelim "$2" "$slash")"
  local -r value="$(colondelim_encodeEntryDelim "$3" "$slash")"
  if [ -z "$value" ]; then
    [ -n "$(colondelim_mapGet "$text" "$key" "$delim" "$slash")" ]
  else
    colondelim_contains "$text" "$key$slash$value" "$delim"
  fi
}

colondelim_mapKeys() {
  local -r text="$1"
  local -r delim="${2:-:}"
  local -r slash="${3:-/}"
  local -r entries="$(colondelim_values "$text" "${key}${slash}${value}" "$delim")"
  local result=""
  for entry in $entries; do
    result="$result${delim}${entry//${slash}*/}"
  done
  echo "$result"
}
