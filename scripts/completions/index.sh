if [ -n "$ZSH_VERSION" ]; then
  source $(cd "$(dirname "$0")"; pwd -P)/zsh.sh
elif [ -n "$BASH_VERSION" ]; then
  source $(cd "$(dirname "$0")"; pwd -P)/bash.sh
fi
