#!/bin/bash -e

source $(dirname "${BASH_SOURCE[0]}")/_base.sh

main() {
  local -i use=0
  local -i save=0
  local -i force=0
  local -r sdk="$(echo "$1" | grep -o "^[^-].*")"

  requireSdkParam "$sdk" || shift

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
        help "update"
        ;;
      -*)
        handleCommonParam "$1"
        ;;
    esac
    shift
  done

  sdk_isLocal "$sdk"
  # [ $force = 1 ] && sdk_isLocalSdk "$sdk" "$version" && sdk_uninstall "$sdk" "$version"
  # sdk_install "$sdk" "$version"
  # [ $use = 1 ] && sdk_enable "$sdk" "$version"
  # [ $save = 1 ] && sdk_saveEnabled "$sdk"
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main $@
