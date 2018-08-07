# This script should be sourced only once
[[ ${UTILS_SPINNER_SOURCED:-} -eq 1 ]] && return || readonly UTILS_SPINNER_SOURCED=1

declare -ig VERBOSE=0
declare -gr SPINNER_STATES="/-\|"
declare SPINNED=0

spinner_spin() {
  printf "\b${SPINNER_STATES:$SPINNED:1}" >&2
  SPINNED="$((SPINNED + 1))"
  if [ "$SPINNED" == "${#SPINNER_STATES}" ]; then
    SPINNED=0
  fi
}

spinner_stop() {
  printf "\b" >&2
}

spin() {
  local line=""
  if [ $VERBOSE = 0 ]; then
    while read line; do
      spinner_spin
    done
    spinner_stop
  else
    while read line; do
      printf "%s\n" "$line"
    done
  fi
}
