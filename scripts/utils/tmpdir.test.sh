#!/bin/bash

source $(dirname "${BASH_SOURCE[0]}")/shunit.sh
source $(dirname "${BASH_SOURCE[0]}")/tmpdir.sh

shouldCreateTmpDir() {
  local -r tmpdir=$(createTmpDir)
  assertDir $tmpdir "Expected tmpdir to be a directory"
  assertStartsWith $tmpdir "/tmp/" "Expected '$tmpdir' to be a subdirectory of /tmp"
}
test shouldCreateTmpDir

shouldCreateTmpDirWithSuffix() {
  local -r suffix="test"
  local -r tmpdir=$(createTmpDir $suffix)
  assertDir $tmpdir "Expected tmpdir to be a directory"
  assertStartsWith $tmpdir "/tmp/" "Expected '$tmpdir' to be a subdirectory of /tmp"
  assertEndsWith $tmpdir "-$suffix" "Expected '$tmpdir' to have a suffix '$suffix'"
}
test shouldCreateTmpDirWithSuffix

shouldRemoveTmpDir() {
  local -r tmpdir=$(createTmpDir)
  removeTmpDir $tmpdir
  assertSuccess
  assertNotExists $tmpdir "Expected tmpdir to not exist"
}
test shouldRemoveTmpDir

shouldNotRemoveTmpDir() {
  local -r dir="/tmp"
  local -r msg="$(removeTmpDir "$dir" 2>&1)"
  assertDir $dir
  assertContains "$msg" "Could not remove temp dir '$dir'. Passed path is not a subpath of /tmp"
}
test shouldNotRemoveTmpDir

shouldNotRemoveNonTmpDir() {
  local -r dir="$(dirname "${BASH_SOURCE[0]}")"
  local -r msg="$(removeTmpDir "$dir" 2>&1)"
  assertDir "$dir"
  assertContains "$msg" "Could not remove temp dir '$dir'. Passed path is not a subpath of /tmp"
}
test shouldNotRemoveNonTmpDir

shouldNotRemoveNotExistingDir() {
  local -r dir="/tmp/non-existing-directory"
  local -r msg="$(removeTmpDir "$dir" 2>&1)"
  assertContains "$msg" "Could not remove temp dir '$dir'. Passed path is not a directory"
}
test shouldNotRemoveNotExistingDir
