sdk_listRemoteSdks() {
  find "$SDKVM_REMOTE_SDKS_DIR" -mindepth 1 -maxdepth 1 -type f ! -name '_*' 2>/dev/null |
    xargs -I '{}' basename {} .sh 2>/dev/null |
    sort
}

sdk_listRemoteSdkVersions() {
  local -r sdk="${1:?Expected SDK}"
  sdk_executeOrEmpty "$sdk" versions | sort -urV
}

sdk_listLocalSdks() {
  find "$SDKVM_LOCAL_SDKS_DIR" -mindepth 1 -maxdepth 1 -type d 2>/dev/null |
    xargs -I '{}' basename {} 2>/dev/null |
    sort
}

sdk_listEnabledSdks() {
  for s in $(sdk_listLocalSdks); do
    if sdk_isEnabled "$s"; then
      echo "$s"
    fi
  done
}

sdk_listLocalSdkVersions() {
  local -r sdk="${1:?Expected SDK}"
  find "$SDKVM_LOCAL_SDKS_DIR/${sdk}" -mindepth 1 -maxdepth 1 -type d 2>/dev/null |
    grep -o '[^/]*$' |
    sort -rV
}

sdk_listAllSdks() {
  echo -e "$(sdk_listLocalSdks)\n$(sdk_listRemoteSdks)" |
    sort -uV |
    sed '/^\s*$/d'
}

sdk_listAllSdkVersions() {
  local -r sdk="${1:?Expected SDK}"
  echo -e "$(sdk_listLocalSdkVersions "$sdk")\n$(sdk_listRemoteSdkVersions "$sdk")" |
    sort -urV |
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
  local -r sdk="${1:?Expected SDK}"
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
