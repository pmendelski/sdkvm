#!/bin/bash -e

source $(dirname "${BASH_SOURCE[0]}")/_base.sh

selfupdate() {
  echo "Updating sdkvm"
  git pull --rebase origin master
}

selfupdate
