if command -v ggrep &>/dev/null; then
  _ggrep() {
    ggrep "$@"
  }
else
  _ggrep() {
    grep "-P $@"
  }
fi

if command -v gsed &>/dev/null; then
  _gsed() {
    gsed "$@"
  }
else
  _gsed() {
    gsed "$@"
  }
fi
