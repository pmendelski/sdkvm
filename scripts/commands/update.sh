#!/bin/bash -e

source $(dirname "${BASH_SOURCE[0]}")/_base.sh

updateSdkvm() {
  printInfo "Updating sdkvm..."
  git pull --rebase origin
}

main() {
  local -i use=1
  local -i save=1
  local -r sdk="$(echo "$1" | grep -o "^[^-].*")"

  [ -n "$sdk" ] && shift

  while (("$#")); do
    case $1 in
      --no-use|-u)
        use=0
        ;;
      --no-save|-s)
        save=0
        ;;
      -*)
        handleCommonParam "$1" "update"
        ;;
    esac
    shift
  done

  if [ -n "$sdk" ]; then
    local -r newestLocal="$(sdk_getNewestLocalSdkVersion "$sdk")"
    local -r newestRemote="$(sdk_getNewestRemoteSdkVersion "$sdk")"
    if [ "$newestLocal" != "$newestRemote" ]; then
      printInfo "Updating $sdk from $newestLocal to $newestRemote"
      sdk_installSdkVersion "$sdk" "$newestRemote"
      [ $use = 1 ] && sdk_enable "$sdk" "$version"
      [ $save = 1 ] && sdk_saveEnabled "$sdk"
    else
      printInfo "SDK $sdk is in the most recent version $newestLocal"
    fi
  else
    updateSdkvm
  fi
  return 0
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main $@
