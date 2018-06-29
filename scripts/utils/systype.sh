# This script should be sourced only once
[[ ${UTILS_SYSTYPE:-} -eq 1 ]] && return || readonly UTILS_SYSTYPE=1

systype() {
  case "$OSTYPE" in
    linux*)
    bsd*)     echo "linux" ;;
    darwin*)  echo "osx" ;;
    solaris*) echo "solaris" ;;
    cygwin*)
    msys*)    echo "windows" ;;
    *)        echo "unknown" ;;
  esac
}

declare -gr SYSTYPE="$(systype)"
