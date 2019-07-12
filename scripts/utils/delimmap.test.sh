#!/usr/bin/env bash

source $(dirname "${BASH_SOURCE[0]}")/shunit.sh
source $(dirname "${BASH_SOURCE[0]}")/delimmap.sh

shouldGetFromMap() {
  local -r text="$1"
  local -r key="$2"
  local -r expected="$3"
  local -r result="$(delimmap_get "$text" "$key")"
  assertEquals "$result" "$expected"
}
test shouldGetFromMap "abc/1:def/1:abc/2" "abc" "1"
test shouldGetFromMap "abc/1:def/1:abc/2" "def" "1"
test shouldGetFromMap "abc/1:d%COLON%ef/1%COLON%2%SLASH%3:abc/2" "d:ef" "1:2/3"
test shouldGetFromMap "abc/1:def/1:abc/2" "jkl" ""

shouldPutToMap() {
  local -r text="$1"
  local -r key="$2"
  local -r value="$3"
  local -r expected="$4"
  local -r colon="$5"
  local -r slash="$6"
  local -r result="$(delimmap_put "$text" "$key" "$value" "$colon" "$slash")"
  assertEquals "$result" "$expected"
}
test shouldPutToMap "abc/1:def/1:abc/2" "abc" "1" "def/1:abc/1"
test shouldPutToMap "def/1" "abc" "1" "def/1:abc/1"
test shouldPutToMap "abc/1:def/1:abc/2" "abc" "3" "def/1:abc/3"
test shouldPutToMap "abc/1:def/1:abc/2" "jkl" "1" "abc/1:def/1:abc/2:jkl/1"
test shouldPutToMap "a\tA\nb\tB" "c" "C" "a\tA\nb\tB\nc\tC" "\n" "\t"

shouldRemoveRemoveEntryFromMap() {
  local -r text="$1"
  local -r key="$2"
  local -r value="$3"
  local -r expected="$4"
  local -r result="$(delimmap_remove "$text" "$key" "$value")"
  assertEquals "$result" "$expected"
}
test shouldRemoveRemoveEntryFromMap "abc/1:def/1:abc/2" "abc" "1" "def/1:abc/2"
test shouldRemoveRemoveEntryFromMap "abc/1:def/1:abc/2" "abc" "2" "abc/1:def/1"
test shouldRemoveRemoveEntryFromMap "abc/1:def/1:abc/2" "def" "1" "abc/1:abc/2"
test shouldRemoveRemoveEntryFromMap "abc/1:def/1:abc/2" "jkl" "1" "abc/1:def/1:abc/2"

shouldRemoveAKeyFromMap() {
  local -r text="$1"
  local -r key="$2"
  local -r expected="$3"
  local -r result="$(delimmap_remove "$text" "$key")"
  assertEquals "$result" "$expected"
}
test shouldRemoveAKeyFromMap "abc/1:def/1:abc/2" "abc" "def/1"
test shouldRemoveAKeyFromMap "abc/1:def/1:abc/2" "def" "abc/1:abc/2"
test shouldRemoveAKeyFromMap "abc/1:def/1:abc/2" "jkl" "abc/1:def/1:abc/2"

shouldContainKeyInMap() {
  local -r text="$1"
  local -r key="$2"
  local -r expected="$4"
  delimmap_contains "$text" "$key"
  assertSuccess
}
test shouldContainKeyInMap "abc/1:def/1:abc/2" "abc"
test shouldContainKeyInMap "abc/1:def/1:abc/2" "def"

shouldContainKeyAndValueInMap() {
  local -r text="$1"
  local -r key="$2"
  local -r value="$3"
  local -r expected="$4"
  delimmap_contains "$text" "$key" "$value"
  assertSuccess
}
test shouldContainKeyAndValueInMap "abc/1:def/1:abc/2" "abc" "1" "def/1:abc/2"
test shouldContainKeyAndValueInMap "abc/1:def/1:abc/2" "abc" "2" "abc/1:def/1"
test shouldContainKeyAndValueInMap "abc/1:def/1:abc/2" "def" "1" "abc/1:abc/2"
test shouldContainKeyAndValueInMap "abc/1:de%SLASH%f/%SLASH%1:abc/2" "de/f" "/1" "abc/1:abc/2"

shouldNotContainInMap() {
  delimmap_contains "$@"
  assertFailure
}
test shouldNotContainInMap "abc/1:def/1:abc/2" "jkl"
test shouldNotContainInMap "abc/1:def/1:abc/2" "abc" "3"

shouldListKeysFromMap() {
  delimmap_contains "$@"
  assertFailure
}
test shouldListKeysFromMap "abc/1:def/1" "abc\ndef"
test shouldListKeysFromMap "abc/1:def/1:abc/2" "abc\ndef"
