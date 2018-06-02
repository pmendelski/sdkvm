#!/bin/bash -e

source $(dirname "${BASH_SOURCE[0]}")/_base.sh

remoteSdkVersions() {
  local -r sdk="$1"
  local -r list="$(sdk_listRemoteSdkVersions "$sdk")"
  printPadded "Remote:"
  printPadded "${list:-none}" 2
}

localSdkVersions() {
  local -r sdk="$1"
  local -r list="$(sdk_listLocalSdkVersions "$sdk")"
  printPadded "Local:"
  printPadded "${list:-none}" 2
}

localSdks() {
  local -r list="$(sdk_listLocalSdks)"
  printPadded "Local:"
  printPadded "${list:-none}" 2
}

remoteSdks() {
  local -r list="$(sdk_listRemoteSdks)"
  printPadded "Remote:"
  printPadded "${list:-none}" 2
}

help() {
  echo "NAME"
  echo "  sdkvm list       Lists available SDKs"
  echo "  sdkvm list SDK   Lists available SDK versions"
  echo ""
  echo "SYNOPSIS"
  echo "  sdkvm list [SDK] [OPTION]..."
  echo ""
  echo "OPTIONS"
  echo "  --local|-l    Prints installed SDKs."
  echo "  --remote|-r   Prints remotely available SDKs."
  echo ""
}

main() {
  local -i local=1
  local -i remote=1
  local -r sdk="$(echo "$1" | grep -o "^[^-].*")"
  local -r version="$(echo "$2" | grep -o "^[^-].*")"

  [ -n "$sdk" ] && shift
  [ -n "$version" ] && shift

  while (("$#")); do
    case $1 in
      --local|-l)
        remote=0
        ;;
      --remote|-r)
        local=0
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
  [ $local = 0 ] && [ $remote = 0 ] \
    && error "Local and remote parameters must not be used together"

  if [ -n "$sdk" ]; then
    println "SDK versions: $sdk"
    [ "$local" == 1 ] && localSdkVersions $sdk
    [ "$remote" == 1 ] && remoteSdkVersions $sdk
  else
    println "SDKs:"
    [ "$local" == 1 ] && localSdks
    [ "$remote" == 1 ] && remoteSdks
  fi
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main $@
