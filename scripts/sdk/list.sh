sdk_listRemoteSdks() {
  find "$SDKVM_REMOTE_SDKS_DIR" -mindepth 1 -maxdepth 1 -type f 2>/dev/null \
    | xargs -I '{}' basename {} .sh 2>/dev/null
}

sdk_listRemoteSdkVersions() {
  local -r sdk="$1"
  sdk_execute "$sdk" versions
}

sdk_listLocalSdks() {
  find "$SDKVM_LOCAL_SDKS_DIR" -mindepth 1 -maxdepth 1 -type d 2>/dev/null \
    | xargs -I '{}' basename {} 2>/dev/null
}

sdk_listLocalSdkVersions() {
  local -r sdk="$1"
  find "$SDKVM_LOCAL_SDKS_DIR/${sdk}" -mindepth 1 -maxdepth 1 -type d 2>/dev/null \
    | xargs -I '{}' basename {} 2>/dev/null
}
