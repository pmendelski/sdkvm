# This script should be sourced only once
[[ ${UTILS_PRINT_SOURCED:-} -eq 1 ]] && return || readonly UTILS_PRINT_SOURCED=1

# Default flags
declare -ig NOCOLOR=0
declare -ig VERBOSE=0

# Colors
declare -rg COLOR_RED=`tput setaf 1`
declare -rg COLOR_GREEN=`tput setaf 2`
declare -rg COLOR_YELLOW=`tput setaf 3`
declare -rg COLOR_BLUE=`tput setaf 4`
declare -rg COLOR_MAGENTA=`tput setaf 5`
declare -rg COLOR_CYAN=`tput setaf 6`
declare -rg COLOR_RESET=`tput sgr0`
declare -rg PADDING='  '

print() {
  echo -ne "$1"
}

println() {
  echo -e "$1"
}

printColor() {
  [ $NOCOLOR = 0 ] \
    && print "$1$2${COLOR_RESET}" \
    || print "$2"
}

printlnColor() {
  [ $NOCOLOR = 0 ] \
    && println "$1$2${COLOR_RESET}" \
    || println "$2"
}

printQuestion() {
  printColor $COLOR_YELLOW "[?] $1"
}

printSuccess() {
  printlnColor $COLOR_GREEN "[ok] $1"
}

printError() {
  (>&2 printlnColor $COLOR_RED "[error] $1")
}

printWarn() {
  (>&2 printlnColor $COLOR_MAGENTA "[warn] $1")
}

printInfo() {
  printlnColor $COLOR_CYAN "$1"
}

printPadded() {
  local -r level="${2:-1}"
  local pad=""
  for (( i=1; i<=$level; i++ )); do
    pad="$pad$PADDING"
  done
  println "$pad${1//$'\n'/$'\n'$pad}"
}

printDebug() {
  [ $VERBOSE -gt 0 ] && println "$1" || :
}

printTrace() {
  [ $VERBOSE -gt 1 ] && println "$1" || :
}
