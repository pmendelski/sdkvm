import ./colondelim

path_remove() {
  colondelim_remove "$PATH" "$1"
}

path_add() {
  colondelim_addAsFirst "$PATH" "$1"
}
