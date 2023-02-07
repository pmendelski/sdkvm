#!/usr/bin/env bash
set -e

source "$(dirname "${BASH_SOURCE[0]}")/_base.sh"

selfVersion() {
  cd "$SDKVM_HOME"
  local version="$(git describe --tags --abbrev=0 2>/dev/null)"
  if [ -z "$version" ]; then
    local -r branch="$(git rev-parse --abbrev-ref HEAD)"
    local -r details="$(git --no-pager log --decorate=short --format='%h, %cd' -n 1)"
    version="$branch ($details)"
  fi
  printDebug "SDKVM version:"
  print "$version"
}

main() {
  handleHelp "self" "$@"
  while (("$#")); do
    case $1 in
    help)
      help
      ;;
    version)
      selfVersion
      ;;
    -*)
      handleCommonParam "$1"
      ;;
    esac
    shift
  done
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main "$@"
