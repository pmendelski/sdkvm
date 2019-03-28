# Script to be sources by all sdkvm commands

source $(dirname "${BASH_SOURCE[0]}")/../utils/import.sh
import utils/print
import utils/error
import sdk

registerErrorTrap

requireParam() {
  local -r name="$1"
  local -r value="$2"
  [ -z "$value" ] && error "Missing parameter \"$name\""
}

requireSdkParam() {
  requireParam "SDK" "$1"
}

requireVersionParam() {
  requireParam "VERSION" "$1"
}

help() {
  local cmdmanfile="${1:+-$1}"
  man $SDKVM_HOME/man/sdkvm$cmdmanfile.1
  exit 0
}

handleHelp() {
  local -r commandName="$1"
  shift
  while (("$#")); do
    case $1 in
      --help|-h)
        help "$commandName"
        ;;
    esac
    shift
  done
}

handleCommonParam() {
  local -r commandName="$2"
  case "$1" in
    --help|-h) help "$commandName" ;;
    --silent|-s) SILENT=1 ;;
    --no-colors|-c) NOCOLORS=1 ;;
    --yes|-y) YES=1 ;;
    --no-icons|-i) NOICONS=1 ;;
    --verbose|-v) VERBOSE=$(($VERBOSE + 1)) ;;
    -vv) VERBOSE=$(($VERBOSE + 2)) ;;
    -vvv) VERBOSE=$(($VERBOSE + 3)) ;;
    *)
      error "Unknown parameter \"$1\". Try --help option."
      ;;
  esac
}
