sdk_install() {
  local -r sdk="$1"
  local -r version="${2:$(sdk_newestRemoteSdkVersion "$sdk")}"
  local -r targetDir="$SDKVM_LOCAL_SDKS_DIR/$sdk/$version"
  if sdk_isLocal "$sdk" "$version"; then
    printInfo "Installing SDK: $sdk v$version"
    sdk_execute "$sdk" install "$version" "$targetDir"
    printInfo "SDK installed successffuly"
  else
    printInfo "SDK is already installed $sdk $version. Skipping..."
  fi
}

sdk_uninstall() {
  local -r sdk="$1"
  local -r version="${2:$(sdk_getEnabledVersion "$sdk")}"
  if sdk_isLocal "$sdk" "$version"; then
    printInfo "SDK is not installed $sdk $version. Skipping..."
  else
    printInfo "Uninstalling SDK: $sdk v$version"
    sdk_disable "$sdk" "$version"
    rm -rf "$SDKVM_LOCAL_SDKS_DIR/$sdk/$version"
    printInfo "SDK uninstalled successffuly"
  fi
}
