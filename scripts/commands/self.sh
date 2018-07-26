#!/bin/bash -e

source $(dirname "${BASH_SOURCE[0]}")/_base.sh

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
        help
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
