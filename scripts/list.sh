#!/bin/bash -e

source $(dirname "${BASH_SOURCE[0]}")/utils/command.sh

remoteSdkVersions() {
  local -r sdk="$1"
  local -r remote="$(sdkvm_list)"
  local -r list="$(listRemoteSdkVersions $1)"
  printPadded "Remote:"
  printPadded "${list:-none}" 2
}

localSdkVersions() {
  local -r list="$(listLocalSdkVersions $1)"
  printPadded "Local:"
  printPadded "${list:-none}" 2
}

localSdks() {
  local -r list="$(listLocalSdks)"
  printPadded "Local:"
  printPadded "${list:-none}" 2
}

remoteSdks() {
  local -r list="$(listRemoteSdks)"
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

declare -i remote=1
declare -i local=1
declare sdk=""

main() {
  if [ -n "$sdk" ]; then
    importSdk "$sdk"
    echo "SDK versions: $sdk"
    [ "$local" == 1 ] && localSdkVersions $sdk
    [ "$remote" == 1 ] && remoteSdkVersions $sdk
  else
    echo "SDKs:"
    [ "$local" == 1 ] && localSdks
    [ "$remote" == 1 ] && remoteSdks
  fi
}

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
      error "Unknown option: $1. Try --help option"
      ;;
    *)
      sdk="$1"
      ;;
  esac
  shift
done
[ $local == 0 ] && [ $remote == 0 ] \
  && error "Local and remote parameters must not be used together"
main
