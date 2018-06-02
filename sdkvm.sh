#!/bin/bash -e
# It is super basic Version Manager for multiple SDKs

declare -xg SDKVM_HOME="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && echo $PWD )"

sdkvm() {
  error() {
    (>&2 echo $1)
    exit 1
  }

  local -r commandsDir="$SDKVM_HOME/scripts/commands"
  case $1 in
    help|--help|-h)
      shift
      "$commandsDir/help.sh" $@
      return
      ;;
    version|--version|-v)
      shift
      "$commandsDir/version.sh" $@
      return
      ;;
    enable|disable)
      # Enable and disable commands update current process variables
      # They must be evaluated locally
      local command="$commandsDir/$1.sh"
      shift
      local output="$($command $@)"
      local exports="$(echo "$output" | sed -nE 's/EVAL: *(.+)$/\1/p')"
      echo -e "$output" | grep -v "EVAL: " || true
      eval "$exports"
      return
      ;;
    -*)
      error "Urecognized option: $1"
      ;;
    *) # Command.
      local -r command="$1"
      [ -z "$command" ] && error "No command defined. Try --help option";
      [[ "$command" != "${command#_}" ]] && error "Invalid command name: \"$command\"";
      $(find "$commandsDir" -mindepth 1 -maxdepth 1 -type f 2>/dev/null | xargs -I '{}' basename {} .sh 2>/dev/null | grep -Fqx "$command") \
        || error "Unrecognized sdkvm command: \"$command\". Try --help option."
      shift
      "$commandsDir/${command}.sh" $@
      return
      ;;
  esac
  error "No command defined. Try --help option"
}

sdkvm_init() {
  local -r sdkDir="$SDKVM_HOME/sdk"
  for file in "$sdkDir"/*/.version; do
    local sdk="$(echo "$file" | sed -En "s|^$sdkDir/([^/]+)/.*|\1|p")"
    local version="$(cat "$file")"
    sdkvm enable "$sdk" "$version" --silent
  done
}

sdkvm_init
