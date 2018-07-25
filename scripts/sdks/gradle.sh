#!/bin/bash -e

source $(dirname "${BASH_SOURCE[0]}")/_base.sh

_sdkvm_versions() {
  echo "4.8.1 https://services.gradle.org/distributions/gradle-4.8.1-bin.zip"
  echo "4.8 https://services.gradle.org/distributions/gradle-4.8-bin.zip"
  echo "4.7 https://services.gradle.org/distributions/gradle-4.7-bin.zip"
  echo "4.6 https://services.gradle.org/distributions/gradle-4.6-bin.zip"
}
