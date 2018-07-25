sdk_getNewestRemoteSdkVersion() {
  local -r sdk="${1?"Expected sdk"}"
  sdk_listRemoteSdkVersions "$sdk" | head -n 1
}

sdk_getNewestLocalSdkVersion() {
  local -r sdk="${1?"Expected sdk"}"
  sdk_listLocalSdkVersions "$sdk" | sort | head -n 1
}

sdk_validateRemoteSdkVersion() {
  local -r sdk="${1?"Expected sdk"}"
  local -r version="${2?"Expected version"}"
  sdk_isRemote "$sdk" "$version" \
    || error "Unrecognized $sdk version: \"$version\""
}

sdk_validateLocalSdkVersion() {
  local -r sdk="${1?"Expected sdk"}"
  local -r version="${2?"Expected version"}"
  sdk_isLocal "$sdk" "$version" \
    || error "Unrecognized $sdk version: \"$version\""
}

sdk_isLocalSdkVersion() {
  local -r sdk="${1?"Expected sdk"}"
  local -r version="${2?"Expected version"}"
  local -r versions="$(sdk_listLocalSdkVersions "$sdk")"
  [ -n "$versions" ] \
    && echo "$versions" | grep -Fq "$version"
}

sdk_isRemoteSdkVersion() {
  local -r sdk="${1?"Expected sdk"}"
  local -r version="${2?"Expected version"}"
  local -r versions="$(sdk_listRemoteSdkVersions "$sdk")"
  [ -n "$versions" ] \
    && echo "$versions" | grep -Fq "$version"
}

sdk_getRemoteSdkVersionDownloadUrl() {
  local -r sdk="$1"
  local -r version="$2"
  sdk_executeOrEmpty "$sdk" versions | grep -E "^$version" | cut -d' ' -f 2
}
