#!/bin/bash -e
# It is super basic Version Manager for multiple SDKs

export SDKVM_HOME="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && echo $PWD )"

sdkvm() {
  local -r commandsDir="$SDKVM_HOME/scripts"
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
    switch)
      # Switch command updates current process variables
      # It must be evaluated locally
      shift
      local exports="$("$commandsDir/switch.sh" $@)"
      eval "$exports"
      return
      ;;
    *) # Command.
      local -r command="$1"
      $(find "$commandsDir" -mindepth 1 -maxdepth 1 -type f 2>/dev/null | xargs -I '{}' basename {} .sh 2>/dev/null | grep -Fqx "$command") \
        || error "Unrecognized sdkvm command: \"$command\". Try --help option."
      shift
      "$commandsDir/${command}.sh" $@
      return
      ;;
  esac
  echo "No option defined"
  echo "Try --help option"
  exit 1;
}
