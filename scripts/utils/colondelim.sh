colondelim_contains() {
  local -r delim=":${1}:"
  local -r tocheck="$2"
  [ "${delim}" != "${delim//:${tocheck}:/}" ]
}

colondelim_remove() {
  local -r delim="$1"
  local -r toremove="$2"
  if [ "$delim" = "$toremove" ]; then
    echo ""
  else
    echo ":${delim}:" \
      | sed "s|:$toremove:|:|" \
      | sed -E 's|:(.*):|\1|'
  fi
}

colondelim_add() {
  local -r delim="$1"
  local -r toadd="$2"
  if [ -z "$delim" ]; then
    echo "$toadd"
  else
    colondelim_contains "$delim" "$toadd" \
      && echo "$delim" \
      || echo "${delim}:${toadd}"
  fi
}

colondelim_replace() {
  local -r delim="$1"
  local -r toreplace="$2"
  local -r replacement="$3"
  echo ":${delim}:" \
    | sed "s|:$toreplace:|:$replacement:|" \
    | sed -E 's|:(.*):|\1|'
}

colondelim_findByPrefix() {
  local -r delim="$1"
  local -r prefix="$2"
  echo "$delim" | sed "s|:|\n|g" | grep "$prefix"
}

colondelim_findFirstByPrefix() {
  colondelim_findByPrefix $@ | head -n 1
}

colondelim_mapGet() {
  local -r delim="$1"
  local -r key="${2}/"
  local -r entry="$(colondelim_findFirstByPrefix "$delim" "$key")"
  echo "${entry#$key}"
}

colondelim_mapPut() {
  local -r delim="$1"
  local -r entry="$2/$3"
  colondelim_add "$delim" "$entry"
}

colondelim_mapRemove() {
  local -r delim="$1"
  local -r key="$2"
  local -r value="$3"
  local -r entries="$(colondelim_findByPrefix "$delim" "$key/$value")"
  local result="$delim"
  for entry in $entries; do
    result="$(colondelim_remove "$result" "$entry")"
  done
  echo "$result"
}

colondelim_mapContains() {
  local -r delim="$1"
  local -r key="$2"
  local -r value="$3"
  if [ -z "$value" ]; then
    [ -n "$(colondelim_mapGet "$delim" "$key")" ]
  else
    colondelim_contains "$delim" "$key/$value"
  fi
}
