declare -g _SDKVM_IMPORTED_SDK=""

sdk__import() {
  _requireSdkFunction() {
    local -r sdk="$1"
    local -r name="$2"
    local -r typeResult="$(type -t $name)"
    if [ -z "$typeResult" ] || [ ! "$typeResult" = function ]; then
      error "Missing sdk module $sdk function: $name"
    fi
  }

  local -r moduleFuns=(
    "_sdkvm_install"
    "_sdkvm_enable"
    "_sdkvm_disable"
    "_sdkvm_versions"
  )
  local -r sdk="$1"
  local -r sdkScript="$SDKVM_REMOTE_SDKS_DIR/${sdk}.sh"
  [ ! -f "$sdkScript" ] && error "Urecognized SDK: \"$sdk\""
  [ "$_SDKVM_IMPORTED_SDK" == "$sdk" ] && return
  [ -z "$sdk" ] && error "Missing SDK parameter"
  [ ! -f "$sdkScript" ] && error "Unrecognized SDK: \"$sdk\" $sdkScript"
  _SDKVM_IMPORTED_SDK=""
  for fun in $moduleFuns; do
    unset -f "$fun"
  done
  source "$sdkScript"
  for fun in $moduleFuns; do
    _requireSdkFunction $sdk "_sdkvm_versions"
  done
  _SDKVM_IMPORTED_SDK="$sdk"
}

sdk_execute() {
  local -r sdk="$1"
  local -r action="_sdkvm_$2"
  shift
  shift
  sdk__import "$sdk" && $action $@
}
