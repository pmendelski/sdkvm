# shellcheck disable=SC2034
# This script should be sourced only once
[[ ${UTILS_ARCHTYPE:-} -eq 1 ]] && return || readonly UTILS_ARCHTYPE=1

archtype() {
  local -r arch="${1:?Expected arch type}"
  case "$arch" in
  386 | i386 | i686 | x86) echo "386" ;;
  amd64 | x86_64) echo "amd64" ;;
  arm) echo "arm" ;;
  arm64 | aarch64) echo "arm64" ;;
  *) echo "unknown" ;;
  esac
}

sysarchtype() {
  archtype "$(uname -m)"
}

declare -gr ARCHTYPE="$(sysarchtype)"
