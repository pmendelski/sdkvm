#!/bin/bash -e

source $(dirname "${BASH_SOURCE[0]}")/_base.sh

function installAllNotInstalledSdks() {
  local -r sdks="$(sdk_listNotInstalledSdks)"
  local sdk=""
  local version=""
  for sdk in $(sdk_listNotInstalledSdks); do
    version="$(sdk_getNewestRemoteSdkVersion "$sdk")"
    sdk_installSdkVersion "$sdk" "$version"
  done
}

main() {
  local -i use=1
  local -i save=1
  local -i force=0
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
      --force|-f)
        force=1
        ;;
      -*)
        handleCommonParam "$1" "install"
        ;;
    esac
    shift
  done

  [ $force = 1 ] && sdk_isLocalSdkVersion "$sdk" "$version" && sdk_uninstallSdkVersion "$sdk" "$version"
  if [ $sdk == "all" ]; then
    installAllNotInstalledSdks
  else
    [ $force = 1 ] && sdk_isLocalSdkVersion "$sdk" "$version" && sdk_uninstallSdkVersion "$sdk" "$version"
    sdk_installSdkVersion "$sdk" "$version"
    [ $use = 1 ] && sdk_enable "$sdk" "$version"
    [ $save = 1 ] && sdk_saveEnabled "$sdk"
  fi
  return 0
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main $@
