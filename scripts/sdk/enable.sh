import utils/colondelim

sdk_getEnabledVersion() {
  local -r sdk="$1"
  echo "$(colondelim_mapGet "$SDKVM_ENABLED" "$sdk")"
}

sdk_enable() {
  if [ -z "$SDKVM_ENABLED" ]; then
    export SDKVM_ENABLED=""
    echo "EVAL: export SDKVM_ENABLED=\"\""
  fi
  local -r sdk="$1"
  local -r version="${2:-$(sdk_getNewestLocalSdkVersion "$sdk")}"
  local -r enabled="$(sdk_getEnabledVersion "$sdk")"
  local -r targetDir="$SDKVM_LOCAL_SDKS_DIR/$sdk/$version"
  if [ -z "$enabled" ] || [ "$enabled" != "$version" ]; then
    printDebug "Enabling SDK $sdk $version"
    SDKVM_ENABLED="$(colondelim_mapPut "$SDKVM_ENABLED" "$sdk" "$version")"
    echo "EVAL: export SDKVM_ENABLED=\"$SDKVM_ENABLED\""
    sdk_execute "$sdk" enable "$version" "$targetDir"
    printInfo "Enabled SDK $sdk $version"
  else
    printInfo "SDK $sdk $version is already enabled. Skipping..."
  fi
}

sdk_disable() {
  if [ -z "$SDKVM_ENABLED" ]; then
    export SDKVM_ENABLED=""
    echo "EVAL: export SDKVM_ENABLED=\"\""
  fi
  local -r sdk="$1"
  local -r version="${2:-$(sdk_getEnabledVersion "$sdk")}"
  local -r enabled="$(sdk_getEnabledVersion "$sdk")"
  local -r targetDir="$SDKVM_LOCAL_SDKS_DIR/$sdk/$version"
  if [ -n "$enabled" ] && [ "$enabled" = "$version" ]; then
    printDebug "Disabling SDK $sdk $version"
    SDKVM_ENABLED="$(colondelim_mapRemove "$SDKVM_ENABLED" "$sdk")"
    echo "EVAL: export SDKVM_ENABLED=\"$SDKVM_ENABLED\""
    sdk_execute "$sdk" disable "$version" "$targetDir"
    printInfo "Disabled SDK $sdk $version"
  else
    printInfo "SDK $sdk $version is already disabled. Skipping..."
  fi
}

sdk_isEnabled() {
  local -r sdk="$1"
  local -r version="${2:-$(sdk_getEnabledVersion "$sdk")}"
  colondelim_mapContains "$SDKVM_ENABLED" "$sdk" "$value"
}

sdk_saveEnabled() {
  local -r sdk="$1"
  local -r version="${2:-$(sdk_getEnabledVersion "$sdk")}"
  [ -z "$version" ] && error "Could not reolve SDK version to persist"
  echo "$version" > "$SDKVM_LOCAL_SDKS_DIR/$sdk/.version"
}

sdk_saveDisabled() {
  local -r sdk="$1"
  local -r enabled="$(enabledSdkVersion "$sdk")"
  local -r version="${2:-$(sdk_getEnabledVersion "$sdk")}"
  if [ "$version" == "$enabled" ]; then
    rm -f "$SDKVM_LOCAL_SDKS_DIR/$sdk/.version"
  fi
}
