sdk_getEnabledVersion() {
  local -r sdk="${1:?Expected SDK}"
  echo "$(delimmap_get "$_SDKVM_ENABLED" "$sdk")"
}

sdk_enable() {
  local -r sdk="${1:?Expected SDK}"
  local -r version="${2:-$(sdk_getNewestLocalSdkVersion "$sdk")}"
  local -r enabled="$(sdk_getEnabledVersion "$sdk")"
  local -r targetDir="$SDKVM_LOCAL_SDKS_DIR/$sdk/$version"
  sdk_validateLocalSdkVersion "$sdk" "$version"
  if [ "$enabled" != "$version" ]; then
    if [ -n "$enabled" ]; then
      sdk_disable "$sdk" "$enabled"
    fi
    printInfo "Enabling SDK $sdk/$version"
    _sdk_enable "$sdk" "$version"
    printDebug "Enabled SDK $sdk/$version"
  else
    printInfo "SDK $sdk $version is already enabled. Skipping..."
  fi
}

_sdk_enable() {
  local -r sdk="${1:?Expected SDK}"
  local -r version="${2:-$(sdk_getNewestLocalSdkVersion "$sdk")}"
  sdk_eval "export _SDKVM_ENABLED=\"$sdk/$version:\$_SDKVM_ENABLED\""
  local -r sdkDir="$SDKVM_LOCAL_SDKS_DIR/$sdk/$version"
  local -r pkgDir="$SDKVM_LOCAL_PKGS_DIR/$sdk/$version"
  sdk_execute "$sdk" enable "$version" "$sdkDir" "$pkgDir"
}

sdk_disable() {
  local -r sdk="${1:?Expected SDK}"
  local -r version="${2:-$(sdk_getEnabledVersion "$sdk")}"
  local -r enabled="$(sdk_getEnabledVersion "$sdk")"
  local -r sdkDir="$SDKVM_LOCAL_SDKS_DIR/$sdk/$version"
  local -r pkgDir="$SDKVM_LOCAL_PKGS_DIR/$sdk/$version"
  if [ -n "$enabled" ] && [ "$enabled" = "$version" ]; then
    printInfo "Disabling SDK $sdk/$version"
    _SDKVM_ENABLED="$(delimmap_remove "$_SDKVM_ENABLED" "$sdk")"
    sdk_eval "export _SDKVM_ENABLED=\"$_SDKVM_ENABLED\""
    sdk_execute "$sdk" disable "$version" "$sdkDir" "$pkgDir"
    printDebug "Disabled SDK $sdk/$version"
  else
    [ -z "$enabled" ] &&
      printInfo "SDK is not enabled. Skipping..." ||
      printInfo "SDK $sdk/$version is not enabled. Enabled version: $enabled. Skipping..."
  fi
}

sdk_isEnabled() {
  local -r sdk="${1:?Expected SDK}"
  local -r version="${2:-$(sdk_getEnabledVersion "$sdk")}"
  delimmap_contains "$_SDKVM_ENABLED" "$sdk" "$value"
}

sdk_isDisabled() {
  ! sdk_isEnabled "$1" "$2"
}

sdk_saveEnabled() {
  local -r sdk="${1:?Expected SDK}"
  local -r version="${2:-$(sdk_getEnabledVersion "$sdk")}"
  [ -z "$version" ] && error "Could not resolve SDK version to persist"
  echo "$version" >"$SDKVM_LOCAL_SDKS_DIR/$sdk/.version"
  rm -f "$SDKVM_LOCAL_SDKS_DIR/$sdk/enabled"
  ln -sf "$SDKVM_LOCAL_SDKS_DIR/$sdk/$version" "$SDKVM_LOCAL_SDKS_DIR/$sdk/enabled"
  echo "" >$SDKVM_LOCAL_SDKS_DIR/$sdk/.enable
  local -r previousEvalFile="$_SDKVM_EVAL_FILE"
  _SDKVM_EVAL_FILE="$SDKVM_LOCAL_SDKS_DIR/$sdk/.enable"
  _sdk_enable $sdk $version
  _SDKVM_EVAL_FILE="$previousEvalFile"
  _sdk_refreshInitScript
  printInfo "Saved default SDK version $sdk/$version"
}

_sdk_refreshInitScript() {
  [ -d "$SDKVM_LOCAL_SDKS_DIR" ] || return 0
  echo "#!/usr/bin/env bash" >"$SDKVM_LOCAL_SDKS_DIR/.init"
  chmod u+x "$SDKVM_LOCAL_SDKS_DIR/.init"
  for file in "$SDKVM_LOCAL_SDKS_DIR"/*/.enable; do
    if [ "$file" != "$SDKVM_LOCAL_SDKS_DIR/*/.enable" ]; then
      cat "$file" >>"$SDKVM_LOCAL_SDKS_DIR/.init"
    fi
  done
  return 0
}

sdk_saveDisabled() {
  local -r sdk="${1:?Expected SDK}"
  local -r enabled="$(sdk_getEnabledVersion "$sdk")"
  local -r version="${2:-$(sdk_getEnabledVersion "$sdk")}"
  if [ "$version" == "$enabled" ]; then
    rm -f "$SDKVM_LOCAL_SDKS_DIR/$sdk/.enable"
    rm -f "$SDKVM_LOCAL_SDKS_DIR/$sdk/.version"
    rm -f "$SDKVM_LOCAL_SDKS_DIR/$sdk/enabled"
  fi
}
