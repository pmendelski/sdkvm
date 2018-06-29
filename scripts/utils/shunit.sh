#!/bin/bash

# This script should be sourced only once
[[ ${__SHUNIT_LOADED:-} -eq 1 ]] && return || readonly __SHUNIT_LOADED=1

# Colors
declare ASSERT_RED=$(tput setaf 1)
declare ASSERT_GREEN=$(tput setaf 2)
declare ASSERT_MAGENTA=$(tput setaf 5)
declare ASSERT_NORMAL=$(tput sgr0)
declare ASSERT_BOLD=$(tput bold)

# Padding
declare -r ASSERT_PADDING="  "

# Runner flags
declare -i bail=0

# Testing state
declare currentTestFile=""
declare currentTestTitle=""
declare -r TEST_FAILURE_SEP="|"
declare -a testFailures=()
declare -i testCount=0

reportFailures() {
  local -r status=$?
  if [ $status != 0 ]; then
    echo -e "\n${ASSERT_BOLD}${ASSERT_RED}Test error: $currentTestFile $currentTestTitle${ASSERT_NORMAL}"
    echo -e "${ASSERT_RED}Shell exit with status code: $status${ASSERT_NORMAL}\n"
    exit 1
  fi
  if [ ${#testFailures[@]} -eq 0 ]; then
    echo -e "\n${ASSERT_BOLD}${ASSERT_GREEN}Tests Passed: ${testCount}${ASSERT_NORMAL}\n"
    exit 0
  fi
  local previousTestTitle=""
  local -i failures=0
  for failure in "${testFailures[@]}"; do
    IFS=$TEST_FAILURE_SEP read -ra a <<<$failure;
    local testFile=${a[0]}
    local testTitle=${a[1]}
    local message=${a[2]}
    if [ ! "$testTitle" == "$previousTestTitle" ]; then
      previousTestTitle=$testTitle
      failures=$((failures + 1))
    fi
  done
  echo -e "\n${ASSERT_BOLD}${ASSERT_RED}Tests Failed: ${failures}/${testCount}${ASSERT_NORMAL}\n"
  exit 1
}

trap reportFailures EXIT

printTestSummary() {
  local printedTestTitle=0
  for failure in "${testFailures[@]}"; do
    IFS=$TEST_FAILURE_SEP read -ra a <<<$failure;
    local testFile=${a[0]}
    local testTitle=${a[1]}
    local message=${a[2]}
    if [ "$testFile" == "$currentTestFile" ] && [ "$testTitle" == "$currentTestTitle" ]; then
      if [ $printedTestTitle -eq 0 ]; then
        printedTestTitle=1
        echo "${ASSERT_PADDING}${ASSERT_RED}✖ ${testTitle}${ASSERT_NORMAL}"
      fi
      echo "${ASSERT_PADDING}${ASSERT_PADDING}${ASSERT_RED}${message}${ASSERT_NORMAL}"
    fi
  done
  if [ $printedTestTitle -eq 0 ]; then
    printedTestTitle=1
    echo "${ASSERT_PADDING}${ASSERT_GREEN}✔ ${currentTestTitle}${ASSERT_NORMAL}"
  fi
}

addFailure() {
  local -r msg="${1:-Failed}"
  local -r escaped="${msg//$'\n'/\\n}"
  local -r entry="${currentTestFile}${TEST_FAILURE_SEP}${currentTestTitle}${TEST_FAILURE_SEP}${escaped}"
  testFailures+=("$entry")
  if [ $bail = 1 ]; then
    exit 1;
  fi
}

test() {
  local -r testName="$1"
  shift
  local -r testTitle="${testName}($@)"
  local -r testFile="${BASH_SOURCE[1]}"
  local -r failureCount=${#testFailures[@]}
  if [ ! "$testFile" == "$currentTestFile" ]; then
    echo -e "\n${ASSERT_BOLD}${ASSERT_MAGENTA}${BASH_SOURCE[1]}${ASSERT_NORMAL}"
  fi
  testCount=$((testCount + 1))
  currentTestFile=$testFile
  currentTestTitle=$testTitle
  $testName "$@"
  if [ $? != 0 ] && [ $failureCount = ${#testFailures[@]} ]; then
    addFailure "Test failure: $testName"
  fi
  printTestSummary
}

runTests() {
  local -r files=${@:-$(find . -name "*.test.sh")}
  for file in $files; do
    source "$file"
  done
}

#############
# Utils
#############

noCtrl() {
  echo -n "$1" \
    | sed -r 's/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g' \
    | sed -e 's/[[:cntrl:]]//g'
}

trim() {
  echo -n "$1" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'
}

trimmedNoCtrl() {
  local result="$(noCtrl "$1")"
  result="$(noCtrl "$result")"
  echo "$result"
}

#############
# Assertions
#############

assertEquals() {
  local -r actual="${1//$'\n'/\\n}"
  local -r expected="${2//$'\n'/\\n}"
  local -r msg="${3:-Expected equal ('$actual' == '$expected')}"

  if [ "$actual" != "$expected" ]; then
    addFailure "$msg"
    return 1
  fi
}

assertNotEquals() {
  local -r actual="${1//$'\n'/\\n}"
  local -r expected="${2//$'\n'/\\n}"
  local -r msg="${3:-Expected not equal ('$actual' != '$expected')}"
  if [ "$actual" = "$expected" ]; then
    addFailure "$msg"
    return 1
  fi
}

assertEmpty() {
  local -r actual=$1
  local -r msg="${2:-Expected empty value. Actual: '$actual'}"
  [ -z "$1" ]
  assertSuccess "$msg"
}

assertSuccess() {
  local -r actual="$?"
  local -r msg="${1:-Expected success operation (status: $actual)}"
  assertEquals "$actual" "0" "$msg"
}

assertFailure() {
  local -r actual="$?"
  local -r msg="${1:-Expected failure operation (status: $actual)}"
  assertNotEquals "$actual" "0" "$msg"
}

assertDir() {
  local -r actual="$1"
  local -r msg="${2:-Expected '$actual' to be a directory}"
  [[ -d "$actual"  ]]
  assertSuccess "$msg"
}

assertFile() {
  local -r actual="$1"
  local -r msg="${2:-Expected '$actual' to be a file}"
  [[ -f "$actual"  ]]
  assertSuccess "$msg"
}

assertExists() {
  local -r actual="$1"
  local -r msg="${2:-Expected '$actual' to exist}"
  [ -e "$actual"  ]
  assertSuccess "$msg"
}

assertNotExists() {
  local -r actual="$1"
  local -r msg="${2:-Expected '$actual' to not exist}"
  [ ! -e "$actual" ]
  assertSuccess "$msg"
}

assertStartsWith() {
  local -r actual="$1"
  local -r prefix="$2"
  local -r msg="${3:-Expected '$actual' to start with '$prefix'}"
  [[ ! "${actual##$prefix}" == "${actual}" ]]
  assertSuccess "$msg"
}

assertEndsWith() {
  local -r actual="$1"
  local -r suffix="$2"
  local -r msg="${3:-Expected '$actual' to end with '$prefix'}"
  [[ ! "${actual%%$suffix}" == "${actual}" ]]
  assertSuccess "$msg"
}

assertContains() {
  local -r actual="$1"
  local -r part="$2"
  local -r msg="${3:-Expected '$actual' to contain '$part'}"
  [[ ! "${actual/$part/}" == "${actual}" ]]
  assertSuccess "$msg"
}

###############################################
# Executed as subshell
# Example: ./shunit.sh *.test.sh
# Must be placed at the bottom of the shunit.sh
###############################################

printHelp() {
  echo "NAME"
  echo "  shunit - Test tool for bash scripts. Source: https://github.com/pmendelski/shunit"
  echo ""
  echo "SYNOPSIS"
  echo "  ./shunit.sh [OPTIONS]... [FILES]"
  echo ""
  echo "OPTIONS"
  echo "  -r, --resume          Resume installation process from last error"
  echo "  -c, --nocolor         Disable colors"
  echo "  -h, --help            Print help"
  echo "  -b, --bail            Stop on first failure"
  echo ""
}

noColors() {
  ASSERT_RED=""
  ASSERT_GREEN=""
  ASSERT_MAGENTA=""
  ASSERT_NORMAL=""
  ASSERT_BOLD=""
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  while (("$#")); do
  case $1 in
    --nocolor|-c)
      noColors
      ;;
    --bail|-b)
      bail=1
      ;;
    --help|-h)
      printHelp
      exit 0
      ;;
    --) # End of all options.
      shift
      break
      ;;
    -?*) # Unidentified option.
      println "Unknown option: $1"
      println "Try --help option"
      exit 1
      ;;
    esac
    shift
  done
  runTests $@
fi
