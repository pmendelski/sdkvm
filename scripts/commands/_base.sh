# Script to be sources by all sdkvm commands

source $(dirname "${BASH_SOURCE[0]}")/../utils/import.sh
import utils/print
import sdk

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

handleCommonParam() {
  case "$1" in
    --silent|-s) SILENT=1 ;;
    --no-colors|-c) NOCOLORS=1 ;;
    --verbose|-v) VERBOSE=$(($VERBOSE + 1)) ;;
    *)
      error "Unknown parameter \"$1\". Try --help option."
      ;;
  esac
}
