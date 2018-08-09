#!/bin/bash -e

source $(dirname "${BASH_SOURCE[0]}")/_base.sh

main() {
  local -r sdkDir="$SDKVM_HOME/sdk"
  [ -d "$sdkDir" ] || return 0
  for file in "$sdkDir"/*/.version; do
    local sdk="$(echo "$file" | sed -En "s|^$sdkDir/([^/]+)/.*|\1|p")"
    local version="$(cat "$file")"
    sdk_enable "$sdk" "$version"
  done
  return 0
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main $@
