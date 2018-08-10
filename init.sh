#!/bin/bash -e

declare -xig SDKVM_DEBUG=0

if [ -n "$ZSH_VERSION" ]; then
  declare -xg SDKVM_HOME="$(dirname ${(%):-%N})"
  source $SDKVM_HOME/scripts/completions/zsh.sh
elif [ -n "$KSH_VERSION" ]; then
  declare -xg SDKVM_HOME="$(dirname ${.sh.file})"
else
  declare -xg SDKVM_HOME="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  source $SDKVM_HOME/scripts/completions/bash.sh
fi

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
        printError "Unrecognized sdkvm command: \"$command\". Try --help option."
        return 1;
      fi
      return
      ;;
  esac
  error "No command defined. Try --help option"
}

sdkvm init > /dev/null
