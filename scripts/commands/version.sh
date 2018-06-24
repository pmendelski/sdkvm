#!/bin/bash -e

source $(dirname "${BASH_SOURCE[0]}")/_base.sh

sdkVersions() {
  local -r sdk="${1?Expected sdk}"
  [ $(sdk_isEnabled "$sdk") ] \
    && sdk_getEnabledVersion "$sdk" \
    || print "SDK is not enabled: \"$sdk\""
}

sdkVersions() {
  local -r enabledSdks="$(sdk_listEnabledSdks)"
  if [ -n "$enabledSdks" ]; then
    for s in $enabledSdks; do
      print "$s: "
      sdk_getEnabledVersion "$s"
    done
  else
    print "There is no enabled SDK"
  fi
}

main() {
  local -r sdk="$(echo "$1" | grep -o "^[^-].*")"
  [ -n "$sdk" ] && shift

  while (("$#")); do
    case $1 in
      --help|-h|help)
        help "version"
        ;;
      -*)
        handleCommonParam "$1"
        ;;
    esac
    shift
  done

  if [ -n "$sdk" ]; then
    sdkVersions "$sdk"
  else
    sdkVersions
  fi
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main $@
