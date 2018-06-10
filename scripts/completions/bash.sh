# TODO: Finish Bash autocompltion

_sdkvm() {
  local cur opts
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  if [ $COMP_CWORD = 1 ];then
    opts="list install uninstall selfupdate update enable disable version --help --verbose --version"
    COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
  fi
  return 0
}

# make zsh emulate bash if necessary
if [[ -n "$ZSH_VERSION" ]]; then
    autoload bashcompinit
    bashcompinit
fi

complete -F _sdkvm sdkvm
