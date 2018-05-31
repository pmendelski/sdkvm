#!/bin/bash -e

source $(dirname "${BASH_SOURCE[0]}")/../utils/command.sh
declare -r SDKVM_SDKS_DIR="$SDKVM_HOME/sdk"

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
  importSdk "$sdk"
  local -r version="${2:-$(sdkvm_list | head -n 1)}"
  validateSdkVersion "$sdk" "$version"
  local -r targetDir="$SDKVM_HOME/sdk/$sdk/$version"
  rm -rf "$targetDir"
  mkdir -p "$targetDir"
  sdkvm_install "$version" "$SDKVM_HOME/sdk/$sdk/$version"
}

main "$1" "$2"
