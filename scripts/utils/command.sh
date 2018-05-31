source $(dirname "${BASH_SOURCE[0]}")/print.sh
declare -r SDKVM_SDKS_DIR="$SDKVM_HOME/sdk"

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

listRemoteSdkVersions() {
  sdkvm_list
}

listLocalSdkVersions() {
  local -r sdk="$1"
  find "$SDKVM_SDKS_DIR/${sdk}" -mindepth 1 -maxdepth 1 -type d 2>/dev/null \
    | xargs -I '{}' basename {} 2>/dev/null
}

listLocalSdks() {
  find "$SDKVM_SDKS_DIR" -mindepth 1 -maxdepth 1 -type d 2>/dev/null \
    | xargs -I '{}' basename {} .sh 2>/dev/null
}

listRemoteSdks() {
  find "$SDKVM_HOME/scripts/sdk" -mindepth 1 -maxdepth 1 -type f 2>/dev/null \
    | xargs -I '{}' basename {} .sh 2>/dev/null
}

validateRemoteSdkVersion() {
  local -r sdk="$1"
  local -r version="$2"
  $(listRemoteSdkVersions | grep -Fqx "$version") || error "Unrecognized $sdk version: \"$version\""
}

validateLocalSdkVersion() {
  local -r sdk="$1"
  local -r version="$2"
  $(listLocalSdkVersions $sdk | grep -Fqx "$version") || error "Unrecognized $sdk version: \"$version\""
}
