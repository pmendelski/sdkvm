#!/usr/bin/env bash

# Cached curl
# This script should be sourced only once
[[ ${UTILS_CCURL:-} -eq 1 ]] && return || readonly UTILS_CCURL=1

declare -g -r CCURL_CACHE_DIR="/tmp/sdkvm/cache"

ccurl() {
  local -r cfile="$CCURL_CACHE_DIR/$(echo "$@" | sha1sum)"
  mkdir -p "$CCURL_CACHE_DIR"
  if [ "$NOCACHE" == 1 ] || ! find "$cfile" -mmin +720 >/dev/null 2>&1; then
    # Fetch if not exists or older than 12h
    curl "$@" >"$cfile"
  fi
  cat "$cfile"
}

ccurl_drop() {
  rm -rf "$CCURL_CACHE_DIR"
}
