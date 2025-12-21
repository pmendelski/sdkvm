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

printAllSdkVersions() {
  local -r allSdks="$(sdk_listAllSdks)"
  if [ -n "$allSdks" ]; then
    for s in $allSdks; do
      version="$(sdk_getEnabledVersion "$s")"
      println "$s: ${version:-N/A}"
    done
  else
    printWarn "There is no enabled SDK"
  fi
}

main() {
  handleHelp "version" "$@"
  local -i all=0
  local -r sdk="$(echo "$1" | grep -o "^[^-].*")"
  [ -n "$sdk" ] && shift

  while (("$#")); do
    case $1 in
    --all | -a)
      all=1
      ;;
    -*)
      handleCommonParam "$1" "version"
      ;;
    esac
    shift
  done

  if [ -n "$sdk" ]; then
    printEnabledSdkVersion "$sdk"
  elif [ "$all" = 1 ]; then
    printAllSdkVersions
  else
    printAllEnabledSdkVersions
  fi
  return 0
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main "$@"
