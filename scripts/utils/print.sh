# This script should be sourced only once
[[ ${UTILS_PRINT_SOURCED:-} -eq 1 ]] && return || readonly UTILS_PRINT_SOURCED=1

# Default flags
declare -i nocolor=0
declare -i silent=0
declare -i verbose=0

# Colors
declare -r COLOR_RED=`tput setaf 1`
declare -r COLOR_GREEN=`tput setaf 2`
declare -r COLOR_YELLOW=`tput setaf 3`
declare -r COLOR_BLUE=`tput setaf 4`
declare -r COLOR_MAGENTA=`tput setaf 5`
declare -r COLOR_CYAN=`tput setaf 6`
declare -r COLOR_RESET=`tput sgr0`
declare -r PADDING='  '

print() {
  [ $silent == 0 ] && printf "$1"
}

println() {
  print "$1\n"
}

printColor() {
  if [ $nocolor = 0 ]; then
    print "$1$2${COLOR_RESET}"
  else
    print "$2"
  fi
}

printlnColor() {
  printColor "$1" "$2\n"
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
  printlnColor $COLOR_MAGENTA "[warn] $1"
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
  [ $verbose = 1 ] && println "$1" || :
}

error() {
  printError "$@";
  exit 1
}
