#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/shunit.sh"
source "$(dirname "${BASH_SOURCE[0]}")/delimlist.sh"

shouldRemoveColonDelimitedValue() {
  local -r text="$1"
  local -r toremove="$2"
  local -r expected="${3:-""}"
  local -r result=$(delimlist_remove "$text" "$toremove")
  assertEquals "$result" "$expected" "Expected \"$text\" with removed \"$toremove\" to be \"$expected\". Actual: \"$result\""
}
test shouldRemoveColonDelimitedValue "abc:def:ghi" "abc" "def:ghi"
test shouldRemoveColonDelimitedValue "abc:def:ghi" "def" "abc:ghi"
test shouldRemoveColonDelimitedValue "abc:def:ghi" "ghi" "abc:def"
test shouldRemoveColonDelimitedValue "abc:de%COLON%f:ghi" "de:f" "abc:ghi"
test shouldRemoveColonDelimitedValue "abc:def:ghi" "jkl" "abc:def:ghi"
test shouldRemoveColonDelimitedValue "abc" "abc" ""

shouldAddColonDelimitedValue() {
  local -r text="$1"
  local -r toadd="$2"
  local -r expected="$3"
  local -r result=$(delimlist_add "$text" "$toadd")
  assertEquals "$result" "$expected" "Expected \"$text\" with added \"$toadd\" to be \"$expected\". Actual: \"$result\""
}
test shouldAddColonDelimitedValue "abc:def:ghi" "jkl" "abc:def:ghi:jkl"
test shouldAddColonDelimitedValue "abc:def:ghi" "abc" "abc:def:ghi"
test shouldAddColonDelimitedValue "abc:def:ghi" "def" "abc:def:ghi"
test shouldAddColonDelimitedValue "abc:def:ghi" "ghi" "abc:def:ghi"
test shouldAddColonDelimitedValue "abc:ghi" "de:f" "abc:ghi:de%COLON%f"
test shouldAddColonDelimitedValue "" "ghi" "ghi"

shoulReplaceColonDelimitedValue() {
  local -r text="$1"
  local -r toreplace="$2"
  local -r replacement="$3"
  local -r expected="$4"
  local -r result=$(delimlist_replace "$text" "$toreplace" "$replacement")
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
  delimlist_contains "$text" "$tocheck"
  assertSuccess "Expected \"$text\" to contain \"$tocheck\""
}
test shouldContainColonDelimitedValue "abc:def:ghi" "abc"
test shouldContainColonDelimitedValue "abc:def:ghi" "def"
test shouldContainColonDelimitedValue "abc:def:ghi" "ghi"
test shouldContainColonDelimitedValue "abc:def:ghi%COLON%" "ghi:"

shouldNotContainColonDelimitedValue() {
  local -r text="$1"
  local -r tocheck="$2"
  delimlist_contains "$text" "$tocheck"
  assertFailure "Expected \"$text\" to not contain \"$tocheck\""
}
test shouldNotContainColonDelimitedValue "abc:def:ghi" "a"
test shouldNotContainColonDelimitedValue "abc:def:ghi" "jkl"

shouldListValues() {
  local -r text="$1"
  local -r expected="$2"
  local -r delim="$3"
  local -r result="$(delimlist_values "$text" "$delim")"
  assertEquals "$result" "$expected"
}
test shouldListValues "abc:def:abc" "abc\ndef\nabc"
test shouldListValues "abc:%COLON%d%COLON%e%COLON%:abc" "abc\n:d:e:\nabc"
test shouldListValues "abc#def#abc" "abc\ndef\nabc" "#"
test shouldListValues "" ""

shouldFindValueByPrefix() {
  local -r text="$1"
  local -r prefix="$2"
  local -r expected="$3"
  local -r result="$(delimlist_findByPrefix "$text" "$prefix")"
  assertEquals "$result" "$expected"
}
test shouldFindValueByPrefix "abc/1:def/1:abc/2" "abc/" "abc/1\nabc/2"
test shouldFindValueByPrefix "abc/1:def/1:abc/2" "def/" "def/1"
test shouldFindValueByPrefix "abc/1:def%COLON%/1:abc/2" "def:/" "def:/1"
test shouldFindValueByPrefix "abc/1:def/1:abc/2" "jkl/" ""

shouldFindFirstValueByPrefix() {
  local -r text="$1"
  local -r prefix="$2"
  local -r expected="$3"
  local -r result="$(delimlist_findFirstByPrefix "$text" "$prefix")"
  assertEquals "$result" "$expected"
}
test shouldFindFirstValueByPrefix "abc/1:def/1:abc/2" "abc/" "abc/1"
test shouldFindFirstValueByPrefix "abc/1:def/1:abc/2" "def/" "def/1"
test shouldFindFirstValueByPrefix "abc/1:def/1:abc/2" "jkl/" ""
