# This script should be sourced only once
[[ ${UTILS_PRINT_ERROR:-} -eq 1 ]] && return || readonly UTILS_PRINT_ERROR=1

source "$(dirname "${BASH_SOURCE[0]}")/print.sh"

declare -g ERROR_DEBUG=${ERROR_DEBUG:-1}

error() {
  local -r message="${1:-Unrecognized error}"
  printError "$message"
  exit 1
}

stacktrace() {
  if [ "$ERROR_DEBUG" -gt "0" ]; then
    echo ""
    local -ri skip="${1:-1}"
    for ((i = $(($skip + 1)); i < ${#FUNCNAME[@]} - 1; i++)); do
      echo " $(($i - $skip)): ${FUNCNAME[$i]}(...) ${BASH_SOURCE[$i + 1]}:${BASH_LINENO[$i]}"
    done
  fi
}

errorTrap() {
  local -ri code="${?:-0}"
  if [ $code != 0 ] && [ $ERROR_DEBUG -gt 0 ]; then
    set +o xtrace
    printError "Detected an error. Status code: $code $(stacktrace)"
  fi
  exit "${code}"
}

registerErrorTrap() {
  trap 'errorTrap' EXIT
}
