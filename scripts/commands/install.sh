#!/bin/bash -e

source $(dirname "${BASH_SOURCE[0]}")/_base.sh

help() {
  echo "NAME"
  echo "  sdkvm install SDK - Install SDK"
  echo ""
  echo "SYNOPSIS"
  echo "  sdkvm install SDK [VERSION] [OPTION]..."
  echo ""
  echo "PARAMETERS"
  echo "  VERSION      Install SDK with version and switch to it."
  echo "               In no version is specified the newest"
  echo "               version is installed."
  echo ""
  echo "OPTIONS"
  echo "  --no-use|-u  Do not switch to the SDK after installing"
  echo "  --no-save|-s Do not save the SDK version as the default one"
  echo "  --no-switch  Alias for --no-use and --no-save"
  echo "  --force|-f   Reinstall the SDK even if it already exists"
  echo ""
  echo "SEE"
  echo "  sdkvm list"
  echo ""
}

main() {
  local -i use=0
  local -i save=0
  local -i force=0
  local -r sdk="$(echo "$1" | grep -o "^[^-].*")"
  local -r version="$(echo "$2" | grep -o "^[^-].*")"

  requireSdkParam "$sdk" || shift
  [ -n "$version" ] && shift

  while (("$#")); do
    case $1 in
      --no-use|-u)
        use=0
        ;;
      --no-save|-s)
        save=0
        ;;
      --force|-f)
        force=1
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

  [ $force = 1 ] && sdk_isLocalSdk "$sdk" "$version" && sdk_uninstall "$sdk" "$version"
  sdk_install "$sdk" "$version"
  [ $use = 1 ] && sdk_enable "$sdk" "$version"
  [ $save = 1 ] && sdk_saveEnabled "$sdk"
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main $@
