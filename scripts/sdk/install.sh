sdk_installSdkVersion() {
  local -r sdk="${1:?Expected SDK}"
  local -r version="${2:-$(sdk_getNewestRemoteSdkVersion "$sdk")}"
  local -r sdkDir="$SDKVM_LOCAL_SDKS_DIR/$sdk"
  local -r targetDir="$sdkDir/$version"
  if sdk_isLocalSdkVersion "$sdk" "$version"; then
    error "SDK is already installed $sdk/$version. Skipping..."
  fi
  printInfo "Installing SDK $sdk/$version"
  sdk_execute "$sdk" install "$version" "$targetDir" "$sdkDir"
  printDebug "SDK installed successffuly $sdk/$version"
}

sdk_installSdkPackages() {
  local -r sdk="${1:?Expected SDK}"
  local -r version="${2:-$(sdk_getNewestRemoteSdkVersion "$sdk")}"
  local -r sdkDir="$SDKVM_LOCAL_SDKS_DIR/$sdk"
  local -r targetDir="$sdkDir/$version"
  local -r sdkPkgEnvName="SDKVM_${sdk^^}_PACKAGES"
  if sdk_hasAction "$sdk" "installPackages"; then
    printInfo "Installing SDK global packages $sdk/$version"
    cd "$targetDir" || error "Dir does not exist $targetDir"
    sdk_execute "$sdk" installPackages "$version" "$targetDir" "$sdkDir"
    printDebug "SDK global packages installed successffuly $sdk/$version"
  elif sdk_hasAction "$sdk" "installPackage" && [ -n "${!sdkPkgEnvName}" ]; then
    printInfo "Installing SDK global packages $sdk/$version"
    cd "$targetDir" || error "Dir does not exist $targetDir"
    for pkg in ${!sdkPkgEnvName}; do
      if [ -n "$pkg" ]; then
        if sdk_execute "$sdk" installPackage "$pkg" "$version" "$targetDir" "$sdkDir"; then
          printInfo "Package installed successfully: $pkg"
        else
          printWarn "Could not install package: $pkg"
        fi
      fi
    done
    printDebug "SDK global packages installed $sdk/$version"
  else
    printInfo "SDK $sdk/$version has no installPackages action defined. Skipping..."
  fi
}

sdk_uninstallSdkVersion() {
  local -r sdk="${1:?Expected SDK}"
  local -r version="${2:?Expected version}"
  if sdk_isLocalSdkVersion "$sdk" "$version"; then
    printInfo "Uninstalling SDK $sdk/$version"
    sdk_isEnabled "$sdk" "$version" && sdk_disable "$sdk" "$version"
    rm -rf "${SDKVM_LOCAL_SDKS_DIR:?}/$sdk/$version"
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
    rm -rf "${SDKVM_LOCAL_SDKS_DIR:?}/$sdk"
  else
    printInfo "SDK is not installed $sdk. Skipping..."
  fi
}
