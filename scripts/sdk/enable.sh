sdk_getEnabledVersion() {
  local -r sdk="${1:?Expected SDK}"
  echo "$(delimmap_get "$SDKVM_ENABLED" "$sdk")"
}

sdk_eval() {
  # All stdout lines that start with "EVAL: " are evaluated in parent process
  (>&2 echo "EVAL: $@")
}

sdk_enable() {
  if [ -z "$SDKVM_ENABLED" ]; then
    export SDKVM_ENABLED=""
    sdk_eval "export SDKVM_ENABLED=\"\""
  fi
  local -r sdk="${1:?Expected SDK}"
  local -r version="${2:-$(sdk_getNewestLocalSdkVersion "$sdk")}"
  local -r enabled="$(sdk_getEnabledVersion "$sdk")"
  local -r targetDir="$SDKVM_LOCAL_SDKS_DIR/$sdk/$version"
  sdk_validateLocalSdkVersion "$sdk" "$version"
  if [ -z "$enabled" ] || [ "$enabled" != "$version" ]; then
    sdk_execute "$sdk" disable "$version" "$targetDir"
    printDebug "Enabling SDK $sdk/$version"
    SDKVM_ENABLED="$(delimmap_put "$SDKVM_ENABLED" "$sdk" "$version")"
    sdk_eval "export SDKVM_ENABLED=\"$SDKVM_ENABLED\""
    sdk_execute "$sdk" enable "$version" "$targetDir"
    printInfo "Enabled SDK $sdk/$version"
  else
    printInfo "SDK $sdk $version is already enabled. Skipping..."
  fi
}

sdk_disable() {
  if [ -z "$SDKVM_ENABLED" ]; then
    export SDKVM_ENABLED=""
    sdk_eval "export SDKVM_ENABLED=\"\""
  fi
  local -r sdk="${1:?Expected SDK}"
  local -r version="${2:-$(sdk_getEnabledVersion "$sdk")}"
  local -r enabled="$(sdk_getEnabledVersion "$sdk")"
  local -r targetDir="$SDKVM_LOCAL_SDKS_DIR/$sdk/$version"
  if [ -n "$enabled" ] && [ "$enabled" = "$version" ]; then
    printDebug "Disabling SDK $sdk/$version"
    SDKVM_ENABLED="$(delimmap_remove "$SDKVM_ENABLED" "$sdk")"
    sdk_eval "export SDKVM_ENABLED=\"$SDKVM_ENABLED\""
    sdk_execute "$sdk" disable "$version" "$targetDir"
    printInfo "Disabled SDK $sdk/$version"
  else
    [ -z "$enabled" ] && \
      printInfo "SDK is not enabled. Skipping..." || \
      printInfo "SDK $sdk/$version is not enabled. Enabled version: $enabled. Skipping..."
  fi
}

sdk_isEnabled() {
  local -r sdk="${1:?Expected SDK}"
  local -r version="${2:-$(sdk_getEnabledVersion "$sdk")}"
  delimmap_contains "$SDKVM_ENABLED" "$sdk" "$value"
}

sdk_saveEnabled() {
  local -r sdk="${1:?Expected SDK}"
  local -r version="${2:-$(sdk_getEnabledVersion "$sdk")}"
  [ -z "$version" ] && error "Could not resolve SDK version to persist"
  echo "$version" > "$SDKVM_LOCAL_SDKS_DIR/$sdk/.version"
  rm -f "$SDKVM_LOCAL_SDKS_DIR/$sdk/enabled"
  ln -sf "$SDKVM_LOCAL_SDKS_DIR/$sdk/$version" "$SDKVM_LOCAL_SDKS_DIR/$sdk/enabled"
}

sdk_saveDisabled() {
  local -r sdk="${1:?Expected SDK}"
  local -r enabled="$(sdk_getEnabledVersion "$sdk")"
  local -r version="${2:-$(sdk_getEnabledVersion "$sdk")}"
  if [ "$version" == "$enabled" ]; then
    rm -f "$SDKVM_LOCAL_SDKS_DIR/$sdk/.version"
    rm -f "$SDKVM_LOCAL_SDKS_DIR/$sdk/enabled"
  fi
}
