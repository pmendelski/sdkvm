#!/bin/bash -e

source $(dirname "${BASH_SOURCE[0]}")/_base.sh

sdkvmVersion() {
  cd "$SDKVM_HOME"
  local version="$(git describe --tags --abbrev=0 2>/dev/null)"
  if [ -z "$version"]; then
    local -r branch="$(git rev-parse --abbrev-ref HEAD )"
    local -r details="$(git --no-pager log --decorate=short --format='%h, %cd' -n 1)"
    version="$branch ($details)"
  fi
  echo "$version"
}

help() {
  echo "NAME"
  echo "  sdkvm version - Prints sdkvm/sdk version"
  echo ""
  echo "SYNOPSIS"
  echo "  sdkvm version [SDK] [OPTION]..."
  echo ""
  echo "PARAMETERS"
  echo "  SDK          Prints the version of currently used SDK"
  echo ""
  echo "OPTIONS"
  echo "  --all|-a     Prints all versions of installed SDKs"
  echo ""
}

main() {
  local -i short=0
  local -i all=0
  local -r sdk="$(echo "$1" | grep -o "^[^-].*")"
  [ -n "$sdk" ] && shift

  while (("$#")); do
    case $1 in
      --all|-a)
        all=1
        ;;
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
    sdk_getEnabledVersion "$sdk"
  else
    sdkvmVersion
  fi
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main $@
