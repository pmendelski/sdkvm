#!/bin/bash

source $(dirname "${BASH_SOURCE[0]}")/shunit.sh
source $(dirname "${BASH_SOURCE[0]}")/error.sh

shouldExitWithNonZeroCode() {
  local -r code="$(error &>/dev/null; echo $?)"
  assertNotEquals "$code" "0" "Expected error command to exit with non 0 status code"
}
test shouldExitWithNonZeroCode

shouldPrintErrroMessageToStdErr() {
  local -r msg="Expected test error"
  local -r result="$(error "$msg" 2>&1 >/dev/null)"
  assertEquals "$(trimmedNoCtrl "$result")" "[error] $msg"
}
test shouldPrintErrroMessageToStdErr

shouldPrintDefaultErrroMessageToStdErr() {
  local -r result="$(error 2>&1 >/dev/null)"
  assertEquals "$(trimmedNoCtrl "$result")" "[error] Unrecognized error"
}
test shouldPrintDefaultErrroMessageToStdErr

shouldPrintStacktraceToStdErr() {
  local -r result="$(trap 'errorTrap 2>&1 >/dev/null' EXIT; error 2>&1 >/dev/null)"
  assertContains "$(trimmedNoCtrl "$result")" "1: shouldPrintStacktraceToStdErr(...) ./scripts/utils/shunit.sh"
}
test shouldPrintStacktraceToStdErr
