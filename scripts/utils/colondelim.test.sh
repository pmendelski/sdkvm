#!/bin/bash

source $(dirname "${BASH_SOURCE[0]}")/shunit.sh
source $(dirname "${BASH_SOURCE[0]}")/colondelim.sh

shouldRemoveColonDelimitedValue() {
  local -r text="$1"
  local -r toremove="$2"
  local -r expected="${3:-""}"
  local -r result=$(colondelim_remove "$text" "$toremove")
  assertEquals "$result" "$expected" "Expected \"$text\" with removed \"$toremove\" to be \"$expected\". Actual: \"$result\""
}
test shouldRemoveColonDelimitedValue "abc:def:ghi" "abc" "def:ghi"
test shouldRemoveColonDelimitedValue "abc:def:ghi" "def" "abc:ghi"
test shouldRemoveColonDelimitedValue "abc:def:ghi" "ghi" "abc:def"
test shouldRemoveColonDelimitedValue "abc:de%COLON%f:ghi" "de:f" "abc:ghi"
test shouldRemoveColonDelimitedValue "abc:def:ghi" "jkl" "abc:def:ghi"

shouldReturnEmptyStringAfterRemovingLastValue() {
  local -r result=$(colondelim_remove "abc" "abc")
  assertEmpty "$result"
}
test shouldReturnEmptyStringAfterRemovingLastValue

shouldAddColonDelimitedValue() {
  local -r text="$1"
  local -r toadd="$2"
  local -r expected="$3"
  local -r result=$(colondelim_add "$text" "$toadd")
  assertEquals "$result" "$expected" "Expected \"$text\" with added \"$toadd\" to be \"$expected\". Actual: \"$result\""
}
test shouldAddColonDelimitedValue "abc:def:ghi" "jkl" "abc:def:ghi:jkl"
test shouldAddColonDelimitedValue "abc:def:ghi" "abc" "abc:def:ghi"
test shouldAddColonDelimitedValue "abc:def:ghi" "def" "abc:def:ghi"
test shouldAddColonDelimitedValue "abc:def:ghi" "ghi" "abc:def:ghi"
test shouldAddColonDelimitedValue "abc:ghi" "de:f" "abc:ghi:de%COLON%f"

shouldAddColonDelimitedValueToEmptyString() {
  local -r text=""
  local -r toadd="abc"
  local -r result=$(colondelim_add "$text" "$toadd")
  assertEquals "$result" "$toadd" "Expected \"$text\" with added \"$toadd\" to be \"$toadd\". Actual: \"$result\""
}
test shouldAddColonDelimitedValueToEmptyString

shoulReplaceColonDelimitedValue() {
  local -r text="$1"
  local -r toreplace="$2"
  local -r replacement="$3"
  local -r expected="$4"
  local -r result=$(colondelim_replace "$text" "$toreplace" "$replacement")
  assertEquals "$result" "$expected" "Expected \"$text\" with replaced \"$toreplace\" with \"$replacement\" to be \"$expected\". Actual: \"$result\""
}
test shoulReplaceColonDelimitedValue "abc:def:ghi" "abc" "X" "X:def:ghi"
test shoulReplaceColonDelimitedValue "abc:def:ghi" "def" "X" "abc:X:ghi"
test shoulReplaceColonDelimitedValue "abc:def:ghi" "ghi" "X" "abc:def:X"
test shoulReplaceColonDelimitedValue "abc:def:ghi" "jkl" "X" "abc:def:ghi"
test shoulReplaceColonDelimitedValue "abc:de%COLON%f:ghi" "de:f" "X:X" "abc:X%COLON%X:ghi"

shouldContainColonDelimitedValue() {
  local -r text="$1"
  local -r tocheck="$2"
  local -r expected="$3"
  colondelim_contains "$text" "$tocheck"
  assertSuccess "Expected \"$text\" to contain \"$tocheck\""
}
test shouldContainColonDelimitedValue "abc:def:ghi" "abc"
test shouldContainColonDelimitedValue "abc:def:ghi" "def"
test shouldContainColonDelimitedValue "abc:def:ghi" "ghi"
test shouldContainColonDelimitedValue "abc:def:ghi%COLON%" "ghi:"

shouldNotContainColonDelimitedValue() {
  local -r text="$1"
  local -r tocheck="$2"
  colondelim_contains "$text" "$tocheck"
  assertFailure "Expected \"$text\" to not contain \"$tocheck\""
}
test shouldNotContainColonDelimitedValue "abc:def:ghi" "a"
test shouldNotContainColonDelimitedValue "abc:def:ghi" "jkl"

shouldFindValueByPrefix() {
  local -r text="$1"
  local -r prefix="$2"
  local -r expected="$3"
  local -r result="$(colondelim_findByPrefix "$text" "$prefix")"
  assertEquals "$result" "$expected"
}
test shouldFindValueByPrefix "abc/1:def/1:abc/2" "abc/" "abc/1\nabc/2"
test shouldFindValueByPrefix "abc/1:def/1:abc/2" "def/" "def/1"
test shouldFindValueByPrefix "abc/1:def/1:abc/2" "jkl/" ""

shouldFindFirstValueByPrefix() {
  local -r text="$1"
  local -r prefix="$2"
  local -r expected="$3"
  local -r result="$(colondelim_findFirstByPrefix "$text" "$prefix")"
  assertEquals "$result" "$expected"
}
test shouldFindFirstValueByPrefix "abc/1:def/1:abc/2" "abc/" "abc/1"
test shouldFindFirstValueByPrefix "abc/1:def/1:abc/2" "def/" "def/1"
test shouldFindFirstValueByPrefix "abc/1:def/1:abc/2" "jkl/" ""

shouldMapGet() {
  local -r text="$1"
  local -r key="$2"
  local -r expected="$3"
  local -r result="$(colondelim_mapGet "$text" "$key")"
  assertEquals "$result" "$expected"
}
test shouldMapGet "abc/1:def/1:abc/2" "abc" "1"
test shouldMapGet "abc/1:def/1:abc/2" "def" "1"
test shouldMapGet "abc/1:def/1:abc/2" "jkl" ""

shouldMapPut() {
  local -r text="$1"
  local -r key="$2"
  local -r value="$3"
  local -r expected="$4"
  local -r colon="$5"
  local -r slash="$6"
  local -r result="$(colondelim_mapPut "$text" "$key" "$value" "$colon" "$slash")"
  assertEquals "$result" "$expected"
}
test shouldMapPut "abc/1:def/1:abc/2" "abc" "1" "def/1:abc/1"
test shouldMapPut "def/1" "abc" "1" "def/1:abc/1"
test shouldMapPut "abc/1:def/1:abc/2" "abc" "3" "def/1:abc/3"
test shouldMapPut "abc/1:def/1:abc/2" "jkl" "1" "abc/1:def/1:abc/2:jkl/1"
test shouldMapPut "a\tA\nb\tB" "c" "C" "a\tA\nb\tB\nc\tC" "\n" "\t"

shouldMapRemoveWithValue() {
  local -r text="$1"
  local -r key="$2"
  local -r value="$3"
  local -r expected="$4"
  local -r result="$(colondelim_mapRemove "$text" "$key" "$value")"
  assertEquals "$result" "$expected"
}
test shouldMapRemoveWithValue "abc/1:def/1:abc/2" "abc" "1" "def/1:abc/2"
test shouldMapRemoveWithValue "abc/1:def/1:abc/2" "abc" "2" "abc/1:def/1"
test shouldMapRemoveWithValue "abc/1:def/1:abc/2" "def" "1" "abc/1:abc/2"
test shouldMapRemoveWithValue "abc/1:def/1:abc/2" "jkl" "1" "abc/1:def/1:abc/2"

shouldMapRemove() {
  local -r text="$1"
  local -r key="$2"
  local -r expected="$3"
  local -r result="$(colondelim_mapRemove "$text" "$key")"
  assertEquals "$result" "$expected"
}
test shouldMapRemove "abc/1:def/1:abc/2" "abc" "def/1"
test shouldMapRemove "abc/1:def/1:abc/2" "def" "abc/1:abc/2"
test shouldMapRemove "abc/1:def/1:abc/2" "jkl" "abc/1:def/1:abc/2"

shouldMapContains() {
  local -r text="$1"
  local -r key="$2"
  local -r expected="$4"
  colondelim_mapContains "$text" "$key"
  assertSuccess
}
test shouldMapContains "abc/1:def/1:abc/2" "abc"
test shouldMapContains "abc/1:def/1:abc/2" "def"

shouldMapContainsWithValue() {
  local -r text="$1"
  local -r key="$2"
  local -r value="$3"
  local -r expected="$4"
  colondelim_mapContains "$text" "$key" "$value"
  assertSuccess
}
test shouldMapContainsWithValue "abc/1:def/1:abc/2" "abc" "1" "def/1:abc/2"
test shouldMapContainsWithValue "abc/1:def/1:abc/2" "abc" "2" "abc/1:def/1"
test shouldMapContainsWithValue "abc/1:def/1:abc/2" "def" "1" "abc/1:abc/2"
test shouldMapContainsWithValue "abc/1:de%SLASH%f/%SLASH%1:abc/2" "de/f" "/1" "abc/1:abc/2"

shouldMapNotContains() {
  colondelim_mapContains "$@"
  assertFailure
}
test shouldMapNotContains "abc/1:def/1:abc/2" "jkl"
test shouldMapNotContains "abc/1:def/1:abc/2" "abc" "3"
