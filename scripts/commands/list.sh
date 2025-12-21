#!/usr/bin/env bash
set -e

source "$(dirname "${BASH_SOURCE[0]}")/_base.sh"

printSdks() {
  local -r versions="${1:?Expected versions param}"
  println "Local SDKs:"
  for s in $(sdk_listLocalSdks); do
    if [ "$versions" = 1 ]; then
      local remote="$(sdk_getNewestRemoteSdkVersion "$s")"
      printPadded "$s $(sdk_getEnabledVersion "$s") (remote:${remote:-N/A})"
    else
      printPadded "$s"
    fi
  done
  println
  println "Remote SDKs:"
  for s in $(sdk_listRemoteSdks); do
    if [ "$versions" = 1 ]; then
      local remote="$(sdk_getNewestRemoteSdkVersion "$s")"
      printPadded "$s ${remote:-N/A}"
    else
      printPadded "$s"
    fi
  done
}

printSdkVersions() {
  local -r sdk="${1:?Expected SDK}"
  local -r all="${2:?Expected all param}"
  local -r versions="${3:?Expected versions param}"
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
    if [ "$all" = "1" ]; then
      printPadded "$remoteVersions"
    else
      printPadded "$(echo "$remoteVersions" | head -n 10)"
      if [ "$remoteVersionsCount" -gt 10 ]; then
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
  local -i versions=0
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
    --versions)
      versions=1
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
    if [ -n "$sdk" ]; then
      sdk_listAllSdkVersions "$sdk"
    else
      sdk_listAllSdks
    fi
  elif [ "$local" == 1 ]; then
    if [ -n "$sdk" ]; then
      sdk_listLocalSdkVersions "$sdk"
    else
      sdk_listLocalSdks
    fi
  elif [ "$remote" == 1 ]; then
    if [ -n "$sdk" ]; then
      sdk_listRemoteSdkVersions "$sdk"
    else
      sdk_listRemoteSdks
    fi
  else
    if [ -n "$sdk" ]; then
      printSdkVersions "$sdk" "$all" "$versions"
    else
      printSdks "$versions"
    fi
  fi
  return 0
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main "$@"
