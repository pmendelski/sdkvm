#!/bin/bash -e

source $(dirname "${BASH_SOURCE[0]}")/_base.sh

help() {
  echo "NAME"
  echo "  sdkvm enable SDK   Makes SDK available in the command line"
  echo ""
  echo "SYNOPSIS"
  echo "  sdkvm enable SDK [VERSION] [OPTION]..."
  echo ""
  echo "PARAMETERS"
  echo "  VERSION    Install the version of SDK otherwise the newest available version is used."
  echo ""
  echo "OPTIONS"
  echo "  --help -h     Prints help."
  echo "  --save -s     Save the version."
  echo "                Every newly opened terminal will use the new version."
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

  sdk_enable "$sdk" "$version"
  if [ $save = 1 ]; then
    sdk_saveEnabled
  fi
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main $@
