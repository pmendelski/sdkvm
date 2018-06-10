#!/bin/bash -e

source $(dirname "${BASH_SOURCE[0]}")/_base.sh

listFormattedSdks() {
  local -r sdk="$1"
  println "Local:"
  [ -z "$sdk" ] \
    && printPadded "$(sdk_listLocalSdks)" \
    || printPadded "$(sdk_listLocalSdkVersions "$sdk")"
  println
  println "Remote:"
  [ -z "$sdk" ] \
    && printPadded "$(sdk_listRemoteSdks)" \
    || printPadded "$(sdk_listRemoteSdkVersions "$sdk")"
}

help() {
  echo "NAME"
  echo "  sdkvm list       Lists SDKs"
  echo "  sdkvm list SDK   Lists SDK versions"
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
  local -i local=0
  local -i remote=0
  local -r sdk="$(echo "$1" | grep -o "^[^-].*")"

  [ -n "$sdk" ] && shift

  while (("$#")); do
    case $1 in
      --local|-l)
        local=1
        ;;
      --remote|-r)
        remote=1
        ;;
      --all|-a)
        local=1
        remote=1
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
  if [ $local = 0 ] && [ $remote = 0 ]; then
    listFormattedSdks "$sdk"
  elif [ $local = 1 ] && [ $remote = 1 ]; then
    [ -n "$sdk" ] \
      && sdk_listAllSdkVersions "$sdk" \
      || sdk_listAllSdks
  elif [ "$local" == 1 ]; then
    [ -n "$sdk" ] \
      && sdk_listLocalSdkVersions "$sdk" \
      || sdk_listLocalSdks
  else
    [ -n "$sdk" ] \
      && sdk_listRemoteSdkVersions "$sdk" \
      || sdk_listRemoteSdks
  fi
  return 0
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main $@
