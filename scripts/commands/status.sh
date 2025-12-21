#!/usr/bin/env bash
set -e

source "$(dirname "${BASH_SOURCE[0]}")/_base.sh"

printEnabledSdkVersion() {
  local -r sdk="${1:?Expected sdk}"
  if sdk_isEnabled "$sdk"; then
    sdk_getEnabledVersion "$sdk"
  else
    printWarn "SDK is not enabled: \"$sdk\""
  fi
}

printAllEnabledSdkVersions() {
  local -r enabledSdks="$(sdk_listEnabledSdks)"
  if [ -n "$enabledSdks" ]; then
    for s in $enabledSdks; do
      print "$s: "
      sdk_getEnabledVersion "$s"
    done
  else
    printWarn "There is no enabled SDK"
  fi
}

main() {
  handleHelp "version" "$@"
  local -r sdk="$(echo "$1" | grep -o "^[^-].*")"
  [ -n "$sdk" ] && shift

  while (("$#")); do
    case $1 in
    -*)
      handleCommonParam "$1" "version"
      ;;
    esac
    shift
  done

  if [ -n "$sdk" ]; then
    printEnabledSdkVersion "$sdk"
  else
    printAllEnabledSdkVersions
  fi
  return 0
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main "$@"
