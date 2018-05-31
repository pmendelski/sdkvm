#!/bin/bash -e

cd "$SDKVM_HOME"

declare -i short=0

versionShort() {
  local -r v="$(git describe --tags --abbrev=0 2>/dev/null || git rev-parse --abbrev-ref HEAD)"
  echo "sdkvm $v"
}

version() {
  versionShort
  echo ""
  git --no-pager log --decorate=short --format='date: %cd%nhash: %h' -n 1
  echo "url:  $(git remote get-url origin 2>/dev/null || echo "none")"
}

help() {
  echo "NAME"
  echo "  sdkvm version - Prints sdkvm version"
  echo ""
  echo "SYNOPSIS"
  echo "  sdkvm version [OPTION]..."
  echo ""
  echo "OPTIONS"
  echo "  --short|-s   Print version in a short format"
  echo ""
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  while (("$#")); do
    case $1 in
      --short|-s)
        short=1
        ;;
      --help|-h|help)
        help
        exit 0
        ;;
      -?*) # Unidentified option.
        println "Unknown option: $1"
        println "Try --help option"
        exit 1
        ;;
    esac
    shift
  done
  [ "$short" == 1 ] && versionShort || version
fi
