#!/usr/bin/env bash
set -e

source "$(dirname "${BASH_SOURCE[0]}")/_base.sh"

uninstallSdkVersion() {
  local -r sdk="$1"
  local -r version="$2"
  local -i yes="$3"
  if [ $yes = 1 ] || askForConfirmation "Are you sure you want to remove SDK version: $sdk/$version"; then
    sdk_uninstallSdkVersion "$sdk" "$version"
  fi
}

uninstallSdk() {
  local -r sdk="$1"
  local -i yes="$2"
  if [ $yes = 1 ] || askForConfirmation "Are you sure you want to remove all SDK versions: $sdk"; then
    sdk_uninstallSdk "$sdk"
  fi
}

main() {
  handleHelp "uninstall" "$@"
  local -i yes=0
  local -r sdk="$(echo "$1" | grep -o "^[^-].*")"
  local -r version="$(echo "$2" | grep -o "^[^-].*")"

  requireSdkParam "$sdk" || shift
  [ -n "$version" ] && shift

  while (("$#")); do
    case $1 in
    --yes | -y)
      yes=1
      ;;
    -*)
      handleCommonParam "$1" "uninstall"
      ;;
    esac
    shift
  done

  if [ -n "$version" ]; then
    if sdk_isLocalSdkVersion "$sdk" "$version"; then
      uninstallSdkVersion "$sdk" "$version" "$yes"
    else
      printWarn "SDK version was not found: $sdk/$version"
    fi
  else
    if sdk_isLocalSdk "$sdk"; then
      uninstallSdk "$sdk" "$yes"
    else
      printWarn "SDK was not found: $sdk"
    fi
  fi
  return 0
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main "$@"
