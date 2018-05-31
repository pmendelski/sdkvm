__sdkvm_switch() {
  local -r sdk="$1"
  importSdk "${sdk}"
  local -r version="${2:-$(${sdk}_list | head -n 1)}"
  local -r versions="$(${sdk}_list)"
  [[ " ${versions[*]} " != *" ${version} "* ]] && error "Unrecognized $sdk version: \"$version\""
  ${sdk}_switch "$version"
}

echo "export DUPA123=$1"
