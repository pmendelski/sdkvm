sdk_installSdkVersion() {
  local -r sdk="${1:?Expected SDK}"
  local -r version="${2:-$(sdk_getNewestRemoteSdkVersion "$sdk")}"
  local -r targetDir="$SDKVM_LOCAL_SDKS_DIR/$sdk/$version"
  if sdk_isLocalSdkVersion "$sdk" "$version"; then
    error "SDK is already installed $sdk/$version. Skipping..."
  fi
  printInfo "Installing SDK $sdk/$version"
  sdk_execute "$sdk" install "$version" "$targetDir"
  printDebug "SDK installed successffuly $sdk/$version"
}

sdk_uninstallSdkVersion() {
  local -r sdk="${1:?Expected SDK}"
  local -r version="${2:?Expected version}"
  if sdk_isLocalSdkVersion "$sdk" "$version"; then
    printInfo "Uninstalling SDK $sdk/$version"
    sdk_isEnabled "$sdk" "$version" && sdk_disable "$sdk" "$version"
    rm -rf "$SDKVM_LOCAL_SDKS_DIR/$sdk/$version"
    printDebug "SDK uninstalled successffuly $sdk/$version"
  else
    printInfo "SDK is not installed $sdk/$version. Skipping..."
  fi
}

sdk_uninstallSdk() {
  local -r sdk="${1:?Expected SDK}"
  local -r versions="$(sdk_listLocalSdkVersions "$sdk")"
  local version=""
  if [ -n "$versions" ]; then
    printDebug "Uninstalling SDK: $sdk"
    for version in $versions; do
      sdk_uninstallSdkVersion "$sdk" "$version"
    done
    rm -rf "$SDKVM_LOCAL_SDKS_DIR/$sdk"
  else
    printInfo "SDK is not installed $sdk. Skipping..."
  fi
}
