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
    -*)
      printError "Urecognized option: $1"
      return 1;
      ;;
    *) # Command.
      [ -z "$1" ] && error "No command defined. Try --help option";
      [[ "$1" != "${1#_}" ]] && error "Invalid command name: \"$1\"";
      local -r command="$commandsDir/$1.sh"
      if [ -f "$command" ]; then
        shift
        local -r temp="$(mktemp)"
        $command $@ | tee "$temp" | grep -v "EVAL:"
        local exports="$(cat "$temp" | sed -nE 's/EVAL: *(.+)$/\1/p')"
        rm -f "$temp"
        if [ -n "$exports" ]; then
          # echo -e "EVAL: \n$exports"
          eval "$exports"
        fi
      else
        printError "Unrecognized sdkvm command: \"$command\". Try --help option."
        return 1;
      fi
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
