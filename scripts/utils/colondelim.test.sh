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
test shouldRemoveColonDelimitedValue "abc" "abc" ""

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
test shouldAddColonDelimitedValue "" "ghi" "ghi"

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

shouldListValues() {
  local -r text="$1"
  local -r expected="$2"
  local -r delim="$3"
  local -r result="$(colondelim_values "$text" "$delim")"
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
  local -r result="$(colondelim_findByPrefix "$text" "$prefix")"
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
  local -r result="$(colondelim_findFirstByPrefix "$text" "$prefix")"
  assertEquals "$result" "$expected"
}
test shouldFindFirstValueByPrefix "abc/1:def/1:abc/2" "abc/" "abc/1"
test shouldFindFirstValueByPrefix "abc/1:def/1:abc/2" "def/" "def/1"
test shouldFindFirstValueByPrefix "abc/1:def/1:abc/2" "jkl/" ""

shouldGetFromMap() {
  local -r text="$1"
  local -r key="$2"
  local -r expected="$3"
  local -r result="$(colondelim_mapGet "$text" "$key")"
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
  local -r result="$(colondelim_mapPut "$text" "$key" "$value" "$colon" "$slash")"
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
  local -r result="$(colondelim_mapRemove "$text" "$key" "$value")"
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
  local -r result="$(colondelim_mapRemove "$text" "$key")"
  assertEquals "$result" "$expected"
}
test shouldRemoveAKeyFromMap "abc/1:def/1:abc/2" "abc" "def/1"
test shouldRemoveAKeyFromMap "abc/1:def/1:abc/2" "def" "abc/1:abc/2"
test shouldRemoveAKeyFromMap "abc/1:def/1:abc/2" "jkl" "abc/1:def/1:abc/2"

shouldContainKeyInMap() {
  local -r text="$1"
  local -r key="$2"
  local -r expected="$4"
  colondelim_mapContains "$text" "$key"
  assertSuccess
}
test shouldContainKeyInMap "abc/1:def/1:abc/2" "abc"
test shouldContainKeyInMap "abc/1:def/1:abc/2" "def"

shouldContainKeyAndValueInMap() {
  local -r text="$1"
  local -r key="$2"
  local -r value="$3"
  local -r expected="$4"
  colondelim_mapContains "$text" "$key" "$value"
  assertSuccess
}
test shouldContainKeyAndValueInMap "abc/1:def/1:abc/2" "abc" "1" "def/1:abc/2"
test shouldContainKeyAndValueInMap "abc/1:def/1:abc/2" "abc" "2" "abc/1:def/1"
test shouldContainKeyAndValueInMap "abc/1:def/1:abc/2" "def" "1" "abc/1:abc/2"
test shouldContainKeyAndValueInMap "abc/1:de%SLASH%f/%SLASH%1:abc/2" "de/f" "/1" "abc/1:abc/2"

shouldNotContainInMap() {
  colondelim_mapContains "$@"
  assertFailure
}
test shouldNotContainInMap "abc/1:def/1:abc/2" "jkl"
test shouldNotContainInMap "abc/1:def/1:abc/2" "abc" "3"

shouldListKeysFromMap() {
  colondelim_mapContains "$@"
  assertFailure
}
test shouldListKeysFromMap "abc/1:def/1" "abc\ndef"
test shouldListKeysFromMap "abc/1:def/1:abc/2" "abc\ndef"
