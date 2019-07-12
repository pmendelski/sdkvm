#!/usr/bin/env bash
set -e

source $(dirname "${BASH_SOURCE[0]}")/_base.sh

printEnabledSdkVersion() {
  local -r sdk="${1:?Expected sdk}"
  sdk_isEnabled "$sdk" \
    && sdk_getEnabledVersion "$sdk" \
    || printWarn "SDK is not enabled: \"$sdk\""
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

  [ -n "$sdk" ] && \
    printEnabledSdkVersion "$sdk" || \
    printAllEnabledSdkVersions

  return 0
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main $@
