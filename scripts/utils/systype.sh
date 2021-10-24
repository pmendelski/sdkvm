# This script should be sourced only once
[[ ${UTILS_SYSTYPE:-} -eq 1 ]] && return || readonly UTILS_SYSTYPE=1

systype() {
  case "$OSTYPE" in
    linux*)   echo "linux" ;;
    bsd*)     echo "linux" ;;
    darwin*)  echo "macos" ;;
    solaris*) echo "solaris" ;;
    cygwin*)  echo "windows" ;;
    msys*)    echo "windows" ;;
    *)        echo "unknown" ;;
  esac
}

isUbuntu() {
  [[ "$(uname --all)" == *"Ubuntu"* ]]
}

isLinux() {
  [ "$(systype)" = "linux" ]
}

isMacos() {
  [ "$(systype)" = "macos" ]
}

isMacosWithBrew() {
  isMacos && command -v brew >/dev/null 2>&1
}

declare -gr SYSTYPE="$(systype)"
