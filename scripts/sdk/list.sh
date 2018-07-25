sdk_listRemoteSdks() {
  find "$SDKVM_REMOTE_SDKS_DIR" -mindepth 1 -maxdepth 1 -type f 2>/dev/null ! -name '_*' \
    | xargs -I '{}' basename {} .sh 2>/dev/null
}

sdk_listRemoteSdkVersions() {
  local -r sdk="$1"
  sdk_executeOrEmpty "$sdk" versions | cut -d' ' -f 1
}

sdk_listLocalSdks() {
  find "$SDKVM_LOCAL_SDKS_DIR" -mindepth 1 -maxdepth 1 -type d 2>/dev/null \
    | xargs -I '{}' basename {} 2>/dev/null
}

sdk_listEnabledSdks() {
  for s in $(sdk_listLocalSdks); do
    if sdk_isEnabled "$s"; then
      echo "$s"
    fi
  done
}

sdk_listLocalSdkVersions() {
  # List local SDK versions in dir createion order
  local -r sdk="$1"
  find "$SDKVM_LOCAL_SDKS_DIR/${sdk}" -mindepth 1 -maxdepth 1 -type d 2>/dev/null -printf "%Tx %.8TX %p\n" \
    | sort -r \
    | cut -f 3 -d' ' \
    | grep -o '[^/]*$'
}

sdk_listAllSdks() {
  echo -e "$(sdk_listLocalSdks)\n$(sdk_listRemoteSdks)" | \
    sort -u | \
    sed '/^\s*$/d'
}

sdk_listAllSdkVersions() {
  local -r sdk="$1"
  echo -e "$(sdk_listLocalSdkVersions "$sdk")\n$(sdk_listRemoteSdkVersions "$sdk")" | \
    sort -u | \
    sed '/^\s*$/d'
}

sdk_listNotInstalledSdks() {
  local -r installed="$(sdk_listLocalSdks)"
  local -r remote="$(sdk_listRemoteSdks)"
  local -i contains=0
  for remoteSdk in ${remote[@]}; do
    contains=0
    for installedSdk in ${installed[@]}; do
      if [ "$installedSdk" = "$remoteSdk" ]; then
        contains=1
        break
      fi
    done
    if [ $contains = 0 ]; then
      echo "$remoteSdk"
    fi
  done
}

sdk_listNotInstalledSdkVersions() {
  local -r sdk="$1"
  local -r installed="$(sdk_listLocalSdkVersions "$sdk")"
  local -r remote="$(sdk_listRemoteSdkVersions "$sdk")"
  local -i contains=0
  for remoteSdk in ${remote[@]}; do
    contains=0
    for installedSdk in ${installed[@]}; do
      if [ "$installedSdk" = "$remoteSdk" ]; then
        contains=1
        break
      fi
    done
    if [ $contains = 0 ]; then
      echo "$remoteSdk"
    fi
  done
}
