# TODO: Add Bash compltions

_sdkvm() {
  local cur prev opts
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"
  opts="list install selfupdate enable disable --help --verbose --version"

  if [[ ${cur} == -* ]] ; then
    COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
    return 0
  fi
}

# make zsh emulate bash if necessary
if [[ -n "$ZSH_VERSION" ]]; then
    autoload bashcompinit
    bashcompinit
fi

complete -F _sdkvm sdkvm
