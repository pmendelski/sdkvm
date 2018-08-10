#!/bin/bash -e

source $(dirname "${BASH_SOURCE[0]}")/_base.sh

main() {
  local -r sdkDir="$SDKVM_HOME/sdk"
  [ -d "$sdkDir" ] || return 0
  for file in "$sdkDir"/*/.enable; do
    if [ "$file" != "$sdkDir/*/.enable" ]; then
      cat "$file" >> $_SDKVM_EVAL_FILE
    fi
  done
  return 0
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main $@
