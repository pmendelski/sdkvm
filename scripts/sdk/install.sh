sdk_install() {
  local -r sdk="${1?Expected SDK}"
  local -r version="${2:-$(sdk_getNewestRemoteSdkVersion "$sdk")}"
  local -r targetDir="$SDKVM_LOCAL_SDKS_DIR/$sdk/$version"
  local -r downloadUrl="$(sdk_getRemoteSdkVersionDownloadUrl "$sdk" "$version")"
  if [ -z "$downloadUrl" ]; then
    error "Remote SDK not found: $sdk v$version"
  fi
  if sdk_isLocalSdkVersion "$sdk" "$version"; then
    error "SDK is already installed $sdk $version. Skipping..."
  fi
  printInfo "Installing SDK: $sdk v$version"
  printDebug "Download URL: $downloadUrl"
  sdk_execute "$sdk" install "$version" "$targetDir" "$downloadUrl"
  printInfo "SDK installed successffuly"
}

sdk_uninstall() {
  local -r sdk="$1"
  local -r version="${2:$(sdk_getEnabledSdkVersion "$sdk")}"
  if sdk_isLocal "$sdk" "$version"; then
    printInfo "SDK is not installed $sdk $version. Skipping..."
  else
    printInfo "Uninstalling SDK: $sdk v$version"
    sdk_disable "$sdk" "$version"
    rm -rf "$SDKVM_LOCAL_SDKS_DIR/$sdk/$version"
    printInfo "SDK uninstalled successffuly"
  fi
}
