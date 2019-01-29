#!/bin/bash -e

source $(dirname "${BASH_SOURCE[0]}")/_base.sh
source $(dirname "${BASH_SOURCE[0]}")/idea-ic.sh

_sdkvm_versions() {
  ideaVersions "ideaIU"
}

_sdkvm_install() {
  ideaInstall "ideaIU" "idea-iu" "$1" "$2"
}

_sdkvm_enable() {
  ideaEnable "ideaIU" "IDEA_IU" "$2"
}

_sdkvm_disable() {
  ideaDisable "ideaIU" "IDEA_IU" "$2"
}
