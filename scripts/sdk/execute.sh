declare -g _SDKVM_IMPORTED_SDK=""

sdk__import() {
  _requireSdkFunction() {
    local -r sdk="$1"
    local -r name="$2"
    local -r typeResult="$(type -t "$name")"
    if [ -z "$typeResult" ] || [ ! "$typeResult" = function ]; then
      error "Missing sdk module $sdk function: $name"
    fi
  }

  local -r moduleFuns=(
    "_sdkvm_install"
    "_sdkvm_install_packages"
    "_sdkvm_enable"
    "_sdkvm_disable"
    "_sdkvm_versions"
  )
  local -r requiredFuns=(
    "_sdkvm_install"
    "_sdkvm_enable"
    "_sdkvm_disable"
    "_sdkvm_versions"
  )
  [ "$_SDKVM_IMPORTED_SDK" == "$sdk" ] && return
  local -r sdk="${1:?Expected SDK}"
  local -r sdkScript="$SDKVM_REMOTE_SDKS_DIR/${sdk}.sh"
  [ ! -f "$sdkScript" ] && error "Urecognized SDK: \"$sdk\""
  [ -z "$sdk" ] && error "Missing SDK parameter"
  _SDKVM_IMPORTED_SDK=""
  for fun in "${moduleFuns[@]}"; do
    unset -f "$fun"
  done
  source "$sdkScript"
  for fun in "${requiredFuns[@]}"; do
    _requireSdkFunction "$sdk" "$fun"
  done
  _SDKVM_IMPORTED_SDK="$sdk"
}

sdk_hasAction() {
  local -r sdk="$1"
  local -r action="_sdkvm_$2"
  sdk__import "$sdk"
  local -r typeResult="$(type -t "$action")"
  [ -n "$typeResult" ] && [ "$typeResult" = function ]
}

sdk_execute() {
  local -r sdk="$1"
  local -r action="_sdkvm_$2"
  shift
  shift
  sdk__import "$sdk" &&
    $action "$@"
}

sdk_isDefined() {
  local -r sdk="$1"
  [ -f "$SDKVM_REMOTE_SDKS_DIR/${sdk}.sh" ]
}

sdk_executeOrEmpty() {
  local -r sdk="$1"
  if sdk_isDefined "$sdk"; then
    sdk_execute "$@"
  fi
}
