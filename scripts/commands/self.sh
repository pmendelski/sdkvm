#!/bin/bash -e

source $(dirname "${BASH_SOURCE[0]}")/_base.sh

selfHelp() {
  echo "NAME"
  echo "  sdkvm - Ubuntu SDK version manager."
  echo "  Source: https://github.com/pmendelski/sdkvm"
  echo ""
  echo "SYNOPSIS"
  echo "  sdkvm COMMAND [OPTION]..."
  echo ""
  echo "COMMANDS"
  echo "  install SDK [VERSION]    Install SDK. If no version is specified the newest is picked."
  echo "  uninstall SDK [VERSION]  Delete SDK. If no version is specified all versions are removed."
  echo "  enable SDK [VERSION]     Enable SDK version in the command line. If no version is specified the newest is picked."
  echo "  disable SDK              Disable SDK in the command line."
  echo "  list [SDK]               List all SDKs versions."
  echo "  version [SDK]            Print sdkvm or enabled SDK version."
  echo "  selfupdate               Update sdkvm from the github repository"
  echo ""
  echo "OPTIONS"
  echo "  --help|-h                Print command manual."
  echo "  --silent|-s              No logs."
  echo "  --no-color|-c            No colors in logs"
  echo "  --verbose|-v             Increase log verbosity"
  echo ""
}

selfVersion() {
  cd "$SDKVM_HOME"
  local version="$(git describe --tags --abbrev=0 2>/dev/null)"
  if [ -z "$version"]; then
    local -r branch="$(git rev-parse --abbrev-ref HEAD )"
    local -r details="$(git --no-pager log --decorate=short --format='%h, %cd' -n 1)"
    version="$branch ($details)"
  fi
  printDebug "SDKVM version:"
  print "$version"
}

selfUpdate() {
  printInfo "Updating sdkvm"
  # TODO: Uncomment when finished
  # git pull --rebase origin master
}

main() {
  while (("$#")); do
    case $1 in
      help)
        selfHelp
        ;;
      version)
        selfVersion
        ;;
      update)
        selfUpdate
        ;;
      -*)
        handleCommonParam "$1"
        ;;
    esac
    shift
  done
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main $@
