source $(dirname "${BASH_SOURCE[0]}")/../utils/import.sh
import utils/print
import utils/tmpdir
import utils/extract
import utils/path
import utils/delimmap
import utils/systype

exec() {
  # All stdout lines that start with "EVAL: " are evaluated in parent process
  echo "EVAL: $@"
}

cachedSdks() {
  local -r sdk="$1"
  local -r system="${2:-$SYSTYPE}"

}

indexedSdk() {
  local -r sdk="$1"
  local -r cacheFile="$SDKVM_REMOTE_CACHE_DIR/$sdk"
  if [ ! -f "$cacheFile" ]; then
    error "Remote SDK source was not indexed for $sdk. Please run: sdkvm index $sdk"
  fi
  cat "$SDKVM_REMOTE_CACHE_DIR/$sdk"
}

indexedSdkVersions() {
  local -r sdk="$1"
  local -r index="$(indexedSdk "$sdk")"
  delimmap_get "$index" "$sdk"
}

indexedSdkUrl() {
  local -r sdk="$1"
  local -r cacheFile="$SDKVM_REMOTE_CACHE_DIR/$sdk"
  if [ ! -f "$cacheFile" ]; then
    error "Remote SDK source was not indexed for $sdk. Please run: sdkvm index $sdk"
  fi
  cat "$SDKVM_REMOTE_CACHE_DIR/$sdk"
}
