#!/usr/bin/env bash
set -e

source "$(dirname "${BASH_SOURCE[0]}")/_base.sh"

printSdks() {
  local -r localSdks="$(sdk_listLocalSdks)"
  local -r remoteSdks="$(sdk_listRemoteSdks)"
  if [ -n "$localSdks" ]; then
    println "Local SDKs:"
    printPadded "$(sdk_listLocalSdks)"
  fi
  if [ -n "$remoteVersions" ] && [ -n "$localVersions" ]; then
    println
  fi
  if [ -n "$remoteSdks" ]; then
    println "Remote SDKs:"
    printPadded "$remoteSdks"
  fi
}

printSdkVersions() {
  local -r sdk="${1:?Expected SDK}"
  local -r all="${2:?Expected all param}"
  local -r localVersions="$(sdk_listLocalSdkVersions "$sdk")"
  if [ -n "$localVersions" ]; then
    println "Local SDK versions:"
    printPadded "$localVersions"
  fi
  local -r remoteVersions="$(sdk_listRemoteSdkVersions "$sdk")"
  local -r remoteVersionsCount="$(echo "$remoteVersions" | wc -l)"
  if [ -n "$remoteVersions" ] && [ -n "$localVersions" ]; then
    println
  fi
  if [ -n "$remoteVersions" ]; then
    println "Remote SDK versions:"
    if [ $all = "1" ]; then
      printPadded "$remoteVersions"
    else
      printPadded "$(echo "$remoteVersions" | head -n 10)"
      if [ $remoteVersionsCount -gt 10 ]; then
        printPadded "...and more, total: $remoteVersionsCount"
      fi
    fi
  else
    printWarn "Remote SDK not found: $sdk"
  fi
}

main() {
  handleHelp "list" "$@"
  local -i local=0
  local -i all=0
  local -i remote=0
  local -i flat=0
  local -r sdk="$(echo "$1" | grep -o "^[^-].*")"

  [ -n "$sdk" ] && shift

  while (("$#")); do
    case $1 in
    --local | -l)
      local=1
      ;;
    --all | -a)
      all=1
      ;;
    --remote | -r)
      remote=1
      ;;
    --flat | -f)
      flat=1
      ;;
    -*)
      handleCommonParam "$1" "list"
      ;;
    esac
    shift
  done
  if [ $flat = 1 ]; then
    [ -n "$sdk" ] &&
      sdk_listAllSdkVersions "$sdk" ||
      sdk_listAllSdks
  elif [ "$local" == 1 ]; then
    [ -n "$sdk" ] &&
      sdk_listLocalSdkVersions "$sdk" ||
      sdk_listLocalSdks
  elif [ "$remote" == 1 ]; then
    [ -n "$sdk" ] &&
      sdk_listRemoteSdkVersions "$sdk" ||
      sdk_listRemoteSdks
  else
    [ -n "$sdk" ] &&
      printSdkVersions "$sdk" "$all" ||
      printSdks
  fi
  return 0
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main "$@"
