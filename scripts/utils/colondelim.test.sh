#!/bin/bash

source $(dirname "${BASH_SOURCE[0]}")/shunit.sh
source $(dirname "${BASH_SOURCE[0]}")/colondelim.sh

shouldRemoveColonDelimitedValue() {
  local -r delim="$1"
  local -r toremove="$2"
  local -r expected="${3:-""}"
  local -r result=$(colondelim_remove "$delim" "$toremove")
  assertEquals "$result" "$expected" "Expected \"$delim\" with removed \"$toremove\" to be \"$expected\". Actual: \"$result\""
}
test shouldRemoveColonDelimitedValue "abc:def:ghi" "abc" "def:ghi"
test shouldRemoveColonDelimitedValue "abc:def:ghi" "def" "abc:ghi"
test shouldRemoveColonDelimitedValue "abc:def:ghi" "ghi" "abc:def"
test shouldRemoveColonDelimitedValue "abc:def:ghi" "jkl" "abc:def:ghi"

shouldReturnEmptyStringAfterRemovingLastValue() {
  local -r result=$(colondelim_remove "abc" "abc")
  assertEmpty "$result"
}
test shouldReturnEmptyStringAfterRemovingLastValue

shouldAddColonDelimitedValue() {
  local -r delim="$1"
  local -r toadd="$2"
  local -r expected="$3"
  local -r result=$(colondelim_add "$delim" "$toadd")
  assertEquals "$result" "$expected" "Expected \"$delim\" with added \"$toadd\" to be \"$expected\". Actual: \"$result\""
}
test shouldAddColonDelimitedValue "abc:def:ghi" "jkl" "abc:def:ghi:jkl"
test shouldAddColonDelimitedValue "abc:def:ghi" "abc" "abc:def:ghi"
test shouldAddColonDelimitedValue "abc:def:ghi" "def" "abc:def:ghi"
test shouldAddColonDelimitedValue "abc:def:ghi" "ghi" "abc:def:ghi"

shouldAddColonDelimitedValueToEmptyString() {
  local -r delim=""
  local -r toadd="abc"
  local -r result=$(colondelim_add "$delim" "$toadd")
  assertEquals "$result" "$toadd" "Expected \"$delim\" with added \"$toadd\" to be \"$toadd\". Actual: \"$result\""
}
test shouldAddColonDelimitedValueToEmptyString

shoulReplaceColonDelimitedValue() {
  local -r delim="$1"
  local -r toreplace="$2"
  local -r replacement="$3"
  local -r expected="$4"
  local -r result=$(colondelim_replace "$delim" "$toreplace" "$replacement")
  assertEquals "$result" "$expected" "Expected \"$delim\" with replaced \"$toreplace\" with \"$replacement\" to be \"$expected\". Actual: \"$result\""
}
test shoulReplaceColonDelimitedValue "abc:def:ghi" "abc" "X" "X:def:ghi"
test shoulReplaceColonDelimitedValue "abc:def:ghi" "def" "X" "abc:X:ghi"
test shoulReplaceColonDelimitedValue "abc:def:ghi" "ghi" "X" "abc:def:X"
test shoulReplaceColonDelimitedValue "abc:def:ghi" "jkl" "X" "abc:def:ghi"

shouldContainColonDelimitedValue() {
  local -r delim="$1"
  local -r tocheck="$2"
  local -r expected="$3"
  colondelim_contains "$delim" "$tocheck"
  assertSuccess "Expected \"$delim\" to contain \"$tocheck\""
}
test shouldContainColonDelimitedValue "abc:def:ghi" "abc"
test shouldContainColonDelimitedValue "abc:def:ghi" "def"
test shouldContainColonDelimitedValue "abc:def:ghi" "ghi"

shouldNotContainColonDelimitedValue() {
  local -r delim="$1"
  local -r tocheck="$2"
  colondelim_contains "$delim" "$tocheck"
  assertFailure "Expected \"$delim\" to not contain \"$tocheck\""
}
test shouldNotContainColonDelimitedValue "abc:def:ghi" "a"
test shouldNotContainColonDelimitedValue "abc:def:ghi" "jkl"

shouldFindValueByPrefix() {
  local -r delim="$1"
  local -r prefix="$2"
  local -r expected="$3"
  local -r result="$(colondelim_findByPrefix "$delim" "$prefix")"
  assertEquals "$result" "$expected"
}
test shouldFindValueByPrefix "abc/1:def/1:abc/2" "abc/" "abc/1\nabc/2"
test shouldFindValueByPrefix "abc/1:def/1:abc/2" "def/" "def/1"
test shouldFindValueByPrefix "abc/1:def/1:abc/2" "jkl/" ""

shouldFindFirstValueByPrefix() {
  local -r delim="$1"
  local -r prefix="$2"
  local -r expected="$3"
  local -r result="$(colondelim_findFirstByPrefix "$delim" "$prefix")"
  assertEquals "$result" "$expected"
}
test shouldFindFirstValueByPrefix "abc/1:def/1:abc/2" "abc/" "abc/1"
test shouldFindFirstValueByPrefix "abc/1:def/1:abc/2" "def/" "def/1"
test shouldFindFirstValueByPrefix "abc/1:def/1:abc/2" "jkl/" ""

shouldMapGet() {
  local -r delim="$1"
  local -r key="$2"
  local -r expected="$3"
  local -r result="$(colondelim_mapGet "$delim" "$key")"
  assertEquals "$result" "$expected"
}
test shouldMapGet "abc/1:def/1:abc/2" "abc" "1"
test shouldMapGet "abc/1:def/1:abc/2" "def" "1"
test shouldMapGet "abc/1:def/1:abc/2" "jkl" ""

shouldMapPut() {
  local -r delim="$1"
  local -r key="$2"
  local -r value="$3"
  local -r expected="$4"
  local -r result="$(colondelim_mapPut "$delim" "$key" "$value")"
  assertEquals "$result" "$expected"
}
test shouldMapPut "abc/1:def/1:abc/2" "abc" "1" "abc/1:def/1:abc/2"
test shouldMapPut "abc/1:def/1:abc/2" "abc" "3" "abc/1:def/1:abc/2:abc/3"
test shouldMapPut "abc/1:def/1:abc/2" "jkl" "1" "abc/1:def/1:abc/2:jkl/1"

shouldMapRemoveWithValue() {
  local -r delim="$1"
  local -r key="$2"
  local -r value="$3"
  local -r expected="$4"
  local -r result="$(colondelim_mapRemove "$delim" "$key" "$value")"
  assertEquals "$result" "$expected"
}
test shouldMapRemoveWithValue "abc/1:def/1:abc/2" "abc" "1" "def/1:abc/2"
test shouldMapRemoveWithValue "abc/1:def/1:abc/2" "abc" "2" "abc/1:def/1"
test shouldMapRemoveWithValue "abc/1:def/1:abc/2" "def" "1" "abc/1:abc/2"
test shouldMapRemoveWithValue "abc/1:def/1:abc/2" "jkl" "1" "abc/1:def/1:abc/2"

shouldMapRemove() {
  local -r delim="$1"
  local -r key="$2"
  local -r expected="$3"
  local -r result="$(colondelim_mapRemove "$delim" "$key")"
  assertEquals "$result" "$expected"
}
test shouldMapRemove "abc/1:def/1:abc/2" "abc" "def/1"
test shouldMapRemove "abc/1:def/1:abc/2" "def" "abc/1:abc/2"
test shouldMapRemove "abc/1:def/1:abc/2" "jkl" "abc/1:def/1:abc/2"

shouldMapContains() {
  local -r delim="$1"
  local -r key="$2"
  local -r expected="$4"
  colondelim_mapContains "$delim" "$key"
  assertSuccess
}
test shouldMapContains "abc/1:def/1:abc/2" "abc"
test shouldMapContains "abc/1:def/1:abc/2" "def"

shouldMapContainsWithValue() {
  local -r delim="$1"
  local -r key="$2"
  local -r value="$3"
  local -r expected="$4"
  colondelim_mapContains "$delim" "$key" "$value"
  assertSuccess
}
test shouldMapContainsWithValue "abc/1:def/1:abc/2" "abc" "1" "def/1:abc/2"
test shouldMapContainsWithValue "abc/1:def/1:abc/2" "abc" "2" "abc/1:def/1"
test shouldMapContainsWithValue "abc/1:def/1:abc/2" "def" "1" "abc/1:abc/2"

shouldMapNotContains() {
  colondelim_mapContains "$@"
  assertFailure
}
test shouldMapNotContains "abc/1:def/1:abc/2" "jkl"
test shouldMapNotContains "abc/1:def/1:abc/2" "abc" "3"
