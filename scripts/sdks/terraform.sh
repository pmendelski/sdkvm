#!/usr/bin/env bash
set -e

source "$(dirname "${BASH_SOURCE[0]}")/_base.sh"

os() {
  case "$(uname -s)" in
  Darwin*) echo "darwin" ;;
  Linux*) echo "linux" ;;
  *)
    echo >&2 "Could not resolve os for terraform"
    exit 1
    ;;
  esac
}

arch() {
  case "$(uname -m)" in
  x86_64 | amd64) echo "amd64" ;;
  arm64) echo "arm64" ;;
  *)
    echo >&2 "Could not resolve arch for terraform"
    exit 1
    ;;
  esac
}

downloadUrls() {
  local -r suffix="_$(os)_$(arch).zip"
  ccurl -s "https://releases.hashicorp.com/terraform" |
    grep -oE ">terraform_[^<]+<" |
    grep -oE "[^><]+" |
    sort -Vu |
    sed -e "s|terraform_\(.*\)|https://releases.hashicorp.com/terraform/\1/terraform_\1$suffix|"
}

downloadUrl() {
  local -r version="${1:?Expected version}"
  local -r suffix="_$(os)_$(arch).zip"
  downloadUrls |
    grep "/terraform_$version$suffix" |
    head -n 1
}

# WIP: create index file
# _sdkvm_versions_index() {
#   # https://www.hashicorp.com/security
#   if ! gpg --list-keys | grep -q "72D7468F$"; then
#     gpg --keyserver pgp.mit.edu --recv-keys 72D7468F
#   fi
#   local -r versions="$(curl -s "https://releases.hashicorp.com/terraform" |
#     grep -oE ">terraform_[^<]+<" |
#     grep -oE "[^><]+" |
#     sed "s|^terraform_||" |
#     sort -Vu | tail -n 3)"
#   local tmpdir="$(mktemp -d -t terraform-XXXX)"
#   local versions_json=""
#   for version in $versions; do
#     # echo -e "\nVersion: $version"
#     local version_html="$(curl -s "https://releases.hashicorp.com/terraform/$version")"
#     local sums="$(cd "$tmpdir" &&
#       wget -q "https://releases.hashicorp.com/terraform/$version/terraform_${version}_SHA256SUMS" &&
#       wget -q "https://releases.hashicorp.com/terraform/$version/terraform_${version}_SHA256SUMS.sig" &&
#       gpg --verify "./terraform_${version}_SHA256SUMS.sig" "./terraform_${version}_SHA256SUMS" 2>/dev/null &&
#       cat "terraform_${version}_SHA256SUMS")"
#     local packages="$(
#       echo "$version_html" |
#         grep -oE ">terraform_[^<]+<" |
#         grep -v "SHA256SUMS" |
#         grep -oE "[^><]+" |
#         sort -Vu
#     )"
#     local packages_json=""
#     for package in $packages; do
#       local packageSha="$(echo "$sums" | grep "$package" | grep -oE "^[^ ]*")"
#       local packageUrl="https://releases.hashicorp.com/terraform/$version/$package"
#       local package_os="$(echo "$package" | sed -e "s|terraform_${version}_\([^_]\+\)_.\+|\1|")"
#       local package_arch="$(echo "$package" | sed -e "s|terraform_${version}_${package_os}_\([^.]\+\)\..\+|\1|")"
#       # TODO: add release field and keep versions in separate files
#       local package_json="{ \"package\": \"$package\", \"sha\": \"$packageSha\", \"url\": \"$packageUrl\", \"os\": \"$(systype "$package_os")\", \"arch\": \"$(archtype "$package_arch")\" }"
#       packages_json="$packages_json$package_json,\n"
#     done
#     local version_json="{ \"version\": \"$version\", \"packages\": [${packages_json%,*}]}"
#     versions_json="$versions_json$version_json,\n"
#   done
#   versions_json="${versions_json%,*}"
#   echo -e "{ \"name\": \"terraform\", \"versions\":[${versions_json}] }" | jq '.'
# }

_sdkvm_versions() {
  local -r suffix="_$(os)_$(arch).zip"
  downloadUrls |
    sed "s|^.*/terraform_||" |
    sed "s|$suffix$||"
}

_sdkvm_install() {
  local -r version="$1"
  local -r targetDir="$2"
  extractFromUrl "$(downloadUrl "$version")" "$targetDir"
  mkdir -p "$targetDir/bin"
  mv "$targetDir/terraform" "$targetDir/bin"
}

_sdkvm_enable() {
  setupHomeAndPath "TERRAFORM" "$2"
}

_sdkvm_disable() {
  resetHomeAndPath "TERRAFORM" "$2"
}

# _sdkvm_versions_index
