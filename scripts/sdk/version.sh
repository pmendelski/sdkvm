sdk_getNewestRemoteSdkVersion() {
  local -r sdk="$1"
  sdk_listRemoteSdkVersions "$sdk" | head -n 1
}

sdk_getNewestLocalSdkVersion() {
  local -r sdk="$1"
  sdk_listLocalSdkVersions "$sdk" | sort | head -n 1
}

sdk_validateRemoteSdkVersion() {
  local -r sdk="$1"
  local -r version="$2"
  sdk_isRemote "$sdk" "$version" \
    || error "Unrecognized $sdk version: \"$version\""
}

sdk_validateLocalSdkVersion() {
  local -r sdk="$1"
  local -r version="$2"
  sdk_isLocal "$sdk" "$version" \
    || error "Unrecognized $sdk version: \"$version\""
}

sdk_isLocal() {
  local -r sdk="$1"
  local -r version="$2"
  local -r versions="$(listLocalSdkVersions "$sdk")"
  [ -n "$versions" ] \
    && echo "$versions" | grep -Fq "$version"
}

sdk_isRemote() {
  local -r sdk="$1"
  local -r version="$2"
  local -r versions="$(listRemoteSdkVersions "$sdk")"
  [ -n "$versions" ] \
    && echo "$versions" | grep -Fq "$version"
}
