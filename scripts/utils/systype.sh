# This script should be sourced only once
[[ ${UTILS_SYSTYPE:-} -eq 1 ]] && return || readonly UTILS_SYSTYPE=1

systype() {
  case "$OSTYPE" in
    linux*)   echo "linux" ;;
    bsd*)     echo "linux" ;;
    darwin*)  echo "osx" ;;
    solaris*) echo "solaris" ;;
    cygwin*)  echo "windows" ;;
    msys*)    echo "windows" ;;
    *)        echo "unknown" ;;
  esac
}

isUbuntu() {
  [[ "$(uname -r)" == *"Ubuntu"* ]]
}

declare -gr SYSTYPE="$(systype)"
