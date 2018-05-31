source $(dirname "${BASH_SOURCE[0]}")/print.sh

_requireSdkFunction() {
  local -r sdk="$1"
  local -r name="$2"
  local -r typeResult="$(type -t $name)"
  if [ -z "$typeResult" ] || [ ! "$typeResult" = function ]; then
    error "Missing sdk module $sdk function: $name"
  fi
}

importSdk() {
  local -r sdk="$1"
  [ -z "$sdk" ] && error "Missing SDK parameter"
  [ ! -f "$SDKVM_HOME/scripts/sdk/${sdk}.sh" ] && error "Unrecognized SDK: \"$sdk\""
  unset -f sdkvm_install
  unset -f sdkvm_switch
  unset -f sdkvm_list
  source "$SDKVM_HOME/scripts/sdk/${sdk}.sh"
  _requireSdkFunction $sdk "sdkvm_install"
  _requireSdkFunction $sdk "sdkvm_switch"
  _requireSdkFunction $sdk "sdkvm_list"
}

validateSdkVersion() {
  local -r sdk="$1"
  local -r version="$2"
  $(sdkvm_list | grep -Fqx "$version") || error "Unrecognized $sdk version: \"$version\""
}
