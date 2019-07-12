#!/usr/bin/env bash
set -e

source $(dirname "${BASH_SOURCE[0]}")/_base.sh

function installSdk() {
  local -r sdk="$1"
  local -r version="$2"
  local -r force="$3"
  local -r use="$4"
  local -r save="$5"
  if [ $force = 1 ] || ! sdk_isLocalSdkVersion "$sdk" "$version"; then
    sdk_isLocalSdkVersion "$sdk" "$version" && sdk_uninstallSdkVersion "$sdk" "$version"
    sdk_installSdkVersion "$sdk" "$version"
    [ $use = 1 ] && sdk_enable "$sdk" "$version"
    [ $save = 1 ] && sdk_saveEnabled "$sdk"
  else
    printWarn "Skipping already installed SDK $sdk $version"
  fi
}

function installAllNotInstalledSdks() {
  local -r force="$1"
  local -r use="$2"
  local -r save="$3"
  local sdk=""
  local version=""
  for sdk in $(sdk_listAllSdks | sort); do
    version="$(sdk_getNewestRemoteSdkVersion "$sdk")"
    installSdk "$sdk" "$version" "$force" "$use" "$save"
  done
}

main() {
  handleHelp "install" "$@"
  local -i use=1
  local -i save=1
  local -i force=0
  local -i all=0
  local -r sdk="$(echo "$1" | grep -o "^[^-].*")"
  local -r versionParam="$(echo "$2" | grep -o "^[^-].*")"

  requireSdkParam "$sdk" || shift
  [ -n "$versionParam" ] && shift
  version="${versionParam:-$(sdk_getNewestRemoteSdkVersion "$sdk")}"

  while (("$#")); do
    case $1 in
      --no-use|-u)
        use=0
        ;;
      --no-save|-s)
        save=0
        ;;
      --all|-a)
        all=1
        ;;
      --force|-f)
        force=1
        ;;
      -*)
        handleCommonParam "$1" "install"
        ;;
    esac
    shift
  done

  if [ $all = 1 ]; then
    installAllNotInstalledSdks "$force" "$use" "$save"
  else
    installSdk "$sdk" "$version" "$force" "$use" "$save"
  fi
  return 0
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main $@
