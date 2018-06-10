#!/bin/bash -e

source $(dirname "${BASH_SOURCE[0]}")/_base.sh

sdkVersions() {
  local -r sdk="${1?Expected sdk}"
  [ $(sdk_isEnabled "$sdk") ] \
    && sdk_getEnabledVersion "$sdk" \
    || error "SDK is not enabled: \"$sdk\". Try --help option"
}

sdkVersions() {
  local -r enabledSdks="$(sdk_listEnabledSdks)"
  if [ -n "$enabledSdks" ]; then
    for s in $enabledSdks; do
      print "$s: "
      sdk_getEnabledVersion "$s"
    done
  else
    error "There is no enabled SDK"
  fi
}

help() {
  echo "NAME"
  echo "  sdkvm version     - Prints all enabled SDK versions"
  echo "  sdkvm version SDK - Prints enabled SDK version"
  echo ""
  echo "SYNOPSIS"
  echo "  sdkvm version [SDK] [OPTION]..."
  echo ""
  echo "PARAMETERS"
  echo "  SDK          Prints the version of enabled SDK"
  echo ""
}

main() {
  local -r sdk="$(echo "$1" | grep -o "^[^-].*")"
  [ -n "$sdk" ] && shift

  while (("$#")); do
    case $1 in
      --help|-h|help)
        help
        exit 0
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
