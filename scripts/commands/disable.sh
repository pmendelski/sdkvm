#!/usr/bin/env bash
set -e

source "$(dirname "${BASH_SOURCE[0]}")/_base.sh"

main() {
  handleHelp "disable" "$@"
  local -i save=0
  local -r sdk="$(echo "$1" | grep -o "^[^-].*")"
  local -r version="$(echo "$2" | grep -o "^[^-].*")"

  requireSdkParam "$sdk" || shift
  [ -n "$version" ] && shift

  while (("$#")); do
    case $1 in
    --save | -s)
      save=1
      ;;
    -?*)
      handleCommonParam "$1" "disable"
      ;;
    esac
    shift
  done

  sdk_disable "$sdk" "${version:-$(sdk_getEnabledVersion "$sdk")}"
  [ $save = 1 ] && sdk_saveDisabled "$sdk"
  return 0
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main "$@"
