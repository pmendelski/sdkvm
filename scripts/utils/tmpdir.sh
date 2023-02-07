# This script should be sourced only once
[[ ${UTILS_TMPDIR_SOURCED:-} -eq 1 ]] && return || readonly UTILS_TMPDIR_SOURCED=1

source "$(dirname "${BASH_SOURCE[0]}")/error.sh"

tmpdir_create() {
  local -r suffix=$1
  local -r tmpdir=$([[ -n "$suffix" ]] &&
    mktemp -d --suffix "-$suffix" ||
    mktemp -d)
  if [[ ! "$tmpdir" || ! -d "$tmpdir" ]]; then
    error "Could not create temp dir $tmpdir"
  fi
  echo $tmpdir
}

tmpdir_create_cd() {
  local -r tmpdir="$(tmpdir_create "$@")"
  cd "$tmpdir"
}

tmpdir_remove() {
  local -r tmpdir=$1
  if [[ ! "$tmpdir" ]]; then
    echo "1"
    error "Could not remove temp dir. Missing path parementer $tmpdir"
  fi
  if [[ ! -d "$tmpdir" ]]; then
    echo "2"
    error "Could not remove temp dir '$tmpdir'. Passed path is not a directory"
  fi
  rm -rf "$tmpdir"
}

tmpdir_remove_cwd() {
  local -r tmpdir="$PWD"
  cd ..
  tmpdir_remove "$tmpdir"
}
