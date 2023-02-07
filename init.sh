#!/usr/bin/env bash

if [ "$(bash --version | grep -o -E '[0-9]+' | head -n 1)" -lt 4 ]; then
  echo "Script requires Bash at least v4. Got bash version: $(bash --version)"
  exit 1
fi

declare -xig SDKVM_DEBUG=0

if [ -n "${ZSH_VERSION-}" ]; then
  declare -xg SDKVM_HOME="$(cd "$(dirname ${(%):-%N})" && pwd)"
  source $SDKVM_HOME/scripts/completions/zsh.sh
elif [ -n "${KSH_VERSION-}" ]; then
  declare -xg SDKVM_HOME="$(cd "$(dirname ${.sh.file})" && pwd)"
else
  declare -xg SDKVM_HOME="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"
  source $SDKVM_HOME/scripts/completions/bash.sh
fi

sdkvm() {
  local -r commandsDir="$SDKVM_HOME/scripts/commands"

  error() {
    (>&2 echo $1)
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
    -*)
      error "Urecognized option: $1"
      return 1;
      ;;
    *) # Command.
      [ -z "$1" ] && error "No command defined. Try --help option";
      [[ "$1" != "${1#_}" ]] && error "Invalid command name: \"$1\"";
      local -r command="$commandsDir/$1.sh"
      if [ -f "$command" ]; then
        shift
        export _SDKVM_EVAL_FILE="$(mktemp)"
        $command $@
        local evals="$(cat "$_SDKVM_EVAL_FILE")"
        rm -f "$_SDKVM_EVAL_FILE"
        unset _SDKVM_EVAL_FILE
        if [ -n "$evals" ]; then
          # echo -e "EVAL: \n=====\n$evals\n====="
          eval "$evals"
        fi
      else
        error "Unrecognized sdkvm command: \"$command\". Try --help option."
        return 1;
      fi
      return
      ;;
  esac
  error "No command defined. Try --help option"
}

_sdkvm_init() {
  local -r initScript="$SDKVM_HOME/sdk/.init"
  if [ -f "$initScript" ]; then
    source "$initScript"
  fi
}

_sdkvm_init
