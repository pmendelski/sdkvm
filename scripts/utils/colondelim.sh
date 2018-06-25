declare -r COLON_REPLACEMENT="%COLON%"
declare -r SLASH_REPLACEMENT="%SLASH%"

colondelim_replaceColons() {
  local -r delim="${2:-:}"
  echo "${1//$delim/$COLON_REPLACEMENT}"
}

colondelim_replaceSlashes() {
  local -r delim="${2:-/}"
  echo "${1//$delim/$SLASH_REPLACEMENT}"
}

colondelim_contains() {
  local -r delim="${3:-:}"
  local -r text="${delim}${1}${delim}"
  local -r tocheck="$(colondelim_replaceColons "$2" "$delim")"
  [ "$text" != "${text//${delim}${tocheck}${delim}/}" ]
}

colondelim_remove() {
  local -r text="$1"
  local -r delim="${3:-:}"
  local -r toremove="$(colondelim_replaceColons "$2" "$delim")"
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
  local -r delim="${3:-:}"
  local -r toadd="$(colondelim_replaceColons "$2" "$delim")"
  if [ -z "$text" ]; then
    echo "$toadd"
  else
    colondelim_contains "$text" "$toadd" "$delim" \
      && echo "$text" \
      || echo "${text}${delim}${toadd}"
  fi
}

colondelim_addAsFirst() {
  local -r delim="${3:-:}"
  local -r text="$(colondelim_remove "$1" "$2" "$delim")"
  local -r toadd="$(colondelim_replaceColons "$2" "$delim")"
  if [ -z "$text" ]; then
    echo "$toadd"
  else
    echo "${toadd}${delim}${text}"
  fi
}

colondelim_replace() {
  local -r text="$1"
  local -r delim="${4:-:}"
  local -r toreplace="$(colondelim_replaceColons "$2" "$delim")"
  local -r replacement="$(colondelim_replaceColons "$3" "$delim")"
  echo "${delim}${text}${delim}" \
    | sed "s|${delim}${toreplace}${delim}|${delim}${replacement}${delim}|" \
    | sed -E "s|${delim}(.*)${delim}|\1|"
}

colondelim_findByPrefix() {
  local -r text="$1"
  local -r delim="${3:-:}"
  local -r prefix="$(colondelim_replaceColons "$2" "$delim")"
  echo "$text" | sed "s|${delim}|\n|g" | grep "$prefix"
}

colondelim_findFirstByPrefix() {
  colondelim_findByPrefix $@ | head -n 1
}

colondelim_mapGet() {
  local -r text="$1"
  local -r delim="${3:-:}"
  local -r slash="${4:-/}"
  local -r key="$(colondelim_replaceSlashes "$2" "$slash")${slash}"
  local -r entry="$(colondelim_findFirstByPrefix "$text" "$key" "$delim")"
  echo "${entry#$key}"
}

colondelim_mapRemove() {
  local -r text="$1"
  local -r delim="${4:-:}"
  local -r slash="${5:-/}"
  local -r key="$(colondelim_replaceSlashes "$2" "$slash")"
  local -r value="$(colondelim_replaceSlashes "$3" "$slash")"
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
  local -r key="$(colondelim_replaceSlashes "$2" "$slash")"
  local -r value="$(colondelim_replaceSlashes "$3" "$slash")"
  colondelim_add "$(colondelim_mapRemove "$text" "$key" "" "$delim" "$slash")" "${key}${slash}${value}" "$delim"
}

colondelim_mapContains() {
  local -r text="$1"
  local -r delim="${4:-:}"
  local -r slash="${5:-/}"
  local -r key="$(colondelim_replaceSlashes "$2" "$slash")"
  local -r value="$(colondelim_replaceSlashes "$3" "$slash")"
  if [ -z "$value" ]; then
    [ -n "$(colondelim_mapGet "$text" "$key" "$delim" "$slash")" ]
  else
    colondelim_contains "$text" "$key$slash$value" "$delim"
  fi
}
