import ./delimlist

path_remove() {
  delimlist_remove "$PATH" "$1"
}

path_add() {
  delimlist_addAsFirst "$PATH" "$1"
}
