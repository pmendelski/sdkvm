# This script should be sourced only once
[[ ${UTILS_SYSTYPE:-} -eq 1 ]] && return || readonly UTILS_SYSTYPE=1

systype() {
  local -r sys="${1:?Expected system type}"
  case "$sys" in
  [Ll]inux*) echo "linux" ;;
  bsd* | BSD* | [Oo]penbsd) echo "openbsd" ;;
  [Ff]reebsd) echo "freebsd" ;;
  [Dd]arwin*) echo "darwin" ;;
  [Ss]olaris*) echo "solaris" ;;
  [Cc]ygwin*) echo "windows" ;;
  [Ww]indows* | [Mm]sys*) echo "windows" ;;
  *) echo "unknown" ;;
  esac
}

ssystype() {
  systype "$OSTYPE"
}

isUbuntu() {
  [[ "$(uname --all)" == *"Ubuntu"* ]]
}

isLinux() {
  [ "$(ssystype)" = "linux" ]
}

isMacos() {
  [ "$(ssystype)" = "darwin" ]
}

isMacosWithBrew() {
  isMacos && command -v brew >/dev/null 2>&1
}

declare -gr SYSTYPE="$(ssystype)"
