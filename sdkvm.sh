#!/bin/bash -e

declare -xg SDKVM_HOME="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
declare -xig SDKVM_DEBUG=0
source "$SDKVM_HOME/scripts/completions/index.sh"

sdkvm() {
  local -r commandsDir="$SDKVM_HOME/scripts/commands"

  error() {
    (>&2 echo $1)
    exit 1
  }

  execute() {
    local command="$1"
    shift
    "$commandsDir/${command}.sh" $@
  }

  executeSelf() {
    local command="$1"
    shift
    shift
    "$commandsDir/self.sh" "$command" $@
  }

  case $1 in
    --help|-h)
      executeSelf "help" $@
      return
      ;;
    --version|-v)
      executeSelf "version" $@
      return
      ;;
    --update|-u)
      executeSelf "update" $@
      return
      ;;
    enable|disable)
      echo "adasdasdasdsad"
      # Enable and disable must be evaluated locally
      # They update current process variables
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
  [ -d "$sdkDir" ] || return
  for file in "$sdkDir"/*/.version; do
    local sdk="$(echo "$file" | sed -En "s|^$sdkDir/([^/]+)/.*|\1|p")"
    local version="$(cat "$file")"
    sdkvm enable "$sdk" "$version" --silent
  done
}

# sdkvm_init
