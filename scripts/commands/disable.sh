#!/bin/bash -e

source $(dirname "${BASH_SOURCE[0]}")/_base.sh

help() {
  echo "NAME"
  echo "  sdkvm disable - Remove SDK form the command line"
  echo ""
  echo "SYNOPSIS"
  echo "  sdkvm disable SDK [VERSION] [OPTION]..."
  echo ""
  echo "PARAMETERS"
  echo "  VERSION    Install the version of SDK otherwise the enabled version is used."
  echo ""
  echo "OPTIONS"
  echo "  --help -h     Prints help."
  echo "  --save -s     Disable version permanently."
  echo "                Every newly opened terminal will nol onger use the version."
  echo ""
  echo "SEE"
  echo "  sdkvm list - Lists sdk versions"
  echo ""
}

main() {
  local -i save=0
  local -r sdk="$(echo "$1" | grep -o "^[^-].*")"
  local -r version="$(echo "$2" | grep -o "^[^-].*")"

  requireSdkParam "$sdk" || shift
  [ -n "$version" ] && shift

  while (("$#")); do
    case $1 in
      --help|-h|help)
        help
        exit 0
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

  sdk_disable "$sdk" "$version"
  [ $save = 1 ] && sdk_saveDisabled
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main $@
