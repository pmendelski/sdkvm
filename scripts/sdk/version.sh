sdk_getNewestRemoteSdkVersion() {
  local -r sdk="${1:?"Expected sdk"}"
  sdk_listRemoteSdkVersions "$sdk" | head -n 1
}

sdk_getNewestLocalSdkVersion() {
  local -r sdk="${1:?"Expected sdk"}"
  sdk_listLocalSdkVersions "$sdk" | head -n 1
}

sdk_validateRemoteSdkVersion() {
  local -r sdk="${1:?"Expected sdk"}"
  local -r version="${2:?"Expected version"}"
  sdk_isRemote "$sdk" "$version" \
    || error "Unrecognized remote $sdk version: \"$version\""
}

sdk_validateLocalSdkVersion() {
  local -r sdk="${1:?"Expected sdk"}"
  local -r version="${2:?"Expected version"}"
  sdk_isLocalSdkVersion "$sdk" "$version" \
    || error "Unrecognized local $sdk version: \"$version\". Available local versions: \n$(sdk_listLocalSdkVersions "$sdk")"
}

sdk_isLocalSdkVersion() {
  local -r sdk="${1:?"Expected sdk"}"
  local -r version="${2:?"Expected version"}"
  local -r versions="$(sdk_listLocalSdkVersions "$sdk")"
  [ -n "$versions" ] \
    && echo "$versions" | grep -Fq "$version"
}

sdk_isLocalSdk() {
  local -r sdk="${1:?"Expected sdk"}"
  local -r versions="$(sdk_listLocalSdkVersions "$sdk")"
  [ -n "$versions" ]
}

sdk_isRemoteSdkVersion() {
  local -r sdk="${1:?"Expected sdk"}"
  local -r version="${2:?"Expected version"}"
  local -r versions="$(sdk_listRemoteSdkVersions "$sdk")"
  [ -n "$versions" ] \
    && echo "$versions" | grep -Fq "$version"
}

sdk_getRemoteSdkVersionDownloadUrl() {
  local -r sdk="${1:?"Expected sdk"}"
  local -r version="${2:?"Expected version"}"
  sdk_executeOrEmpty "$sdk" download_url "$version"
}
