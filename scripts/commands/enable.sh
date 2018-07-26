#!/bin/bash -e

source $(dirname "${BASH_SOURCE[0]}")/_base.sh

main() {
  local -i save=0
  local -r sdk="$(echo "$1" | grep -o "^[^-].*")"
  local -r version="$(echo "$2" | grep -o "^[^-].*")"

  requireSdkParam "$sdk" || shift
  [ -n "$version" ] && shift

  while (("$#")); do
    case $1 in
      --help|-h|help)
        help "enable"
        ;;
      --save|-s)
        save=1
        ;;
      -?*)
        handleCommonParam "$1"
        ;;
    esac
    shift
  done

  sdk_enable "$sdk" "$version"
  [ $save = 1 ] && sdk_saveEnabled "$sdk"
  return 0
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main $@
