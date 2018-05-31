#!/bin/bash -e

source $(dirname "${BASH_SOURCE[0]}")/utils/command.sh

help() {
  echo "NAME"
  echo "  sdkvm install SDK   Installs SDK"
  echo ""
  echo "SYNOPSIS"
  echo "  sdkvm install SDK [VERSION] [OPTION]..."
  echo ""
  echo "PARAMETERS"
  echo "  VERSION     Install the version of SDK otherwise the newest version is used."
  echo ""
  echo "SEE"
  echo "  sdkvm list - Lists sdk versions"
  echo ""
}

declare -i remote=1
declare -i local=1
declare sdk=""

main() {
  local -r sdk="$1"
  local -r newVersion="${2:-$(sdkvm_list | head -n 1)}"
  importSdk "$sdk"
  validateLocalSdkVersion "$sdk" "$newVersion"
  local -r sdkDir="$SDKVM_SDKS_DIR/$sdk"
  local -r versionFile="$sdkDir/.version"
  local -r prevVersion="$([ -f "$versionFile" ] && cat "$versionFile")"
  if [ "$prevVersion" != "$newVersion" ]; then
    sdkvm_switch "$sdkDir" "$newVersion" "$prevVersion"
    echo "$newVersion" > $versionFile
  fi
}

main "$1" "$2"
