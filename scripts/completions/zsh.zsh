compdef _sdkvm sdkvm

# disable sorting sdkvm so versions are not sorted alphabetically
# zstyle ':completion:*:sdkvm:*' sort false

_sdkvm() {
  local ret=1 state
  _arguments -C \
    ':cmd:->cmd' \
    '--version[Display sdkvm version]' \
    '--help[Display sdkvm help]' \
    '--update[Update sdkvm]' \
    '*::options:->options' &&
    ret=0

  case $state in
  cmd)
    local -a commands=(
      'list:List SDKs'
      'version:Display version of enabled SDKs'
      'install:Install SDK'
      'uninstall:Uninstall SDK'
      'enable:Enable SDK'
      'disable:Disable SDK'
      'update:Update SDK'
    )
    _describe -t cmd 'sdkvm cmd' commands &&
      ret=0
    ;;
  options)
    local -a commonOpts=(
      '--no-cache[Disable cache]'
      '--help[Show command help]'
      '--silent[Print no logs]'
      '--no-colors[Use no colors in logs]'
      '--verbose[Increase log verbosity]'
      '--yes[Assume yes for all confirmations]'
    )
    case $words[1] in
    list)
      _arguments \
        "1: :($(sdkvm list --flat))" \
        '--local[List only the installed SDK versions]' \
        '--remote[List only the remote SDK versions]' \
        '--flat[List all SDK versions without grouping]' \
        $commonOpts &&
        ret=0
      ;;
    version)
      _arguments \
        "1: :($(sdkvm list --flat))" \
        $commonOpts &&
        ret=0
      ;;
    install)
      _arguments -w -s -S \
        "1: :($(sdkvm list --remote))" \
        "2: :($(sdkvm list "$words[2]" --remote))" \
        '--all[Install all SDKs]' \
        '--force[Install the SDK version even if it is already installed]' \
        '--no-use[Do not enable the version after installing]' \
        '--no-save[Do not save the version as the default after installing]' \
        $commonOpts &&
        ret=0
      ;;
    uninstall)
      _arguments \
        "1: :($(sdkvm list --local))" \
        "2: :($(sdkvm list "$words[2]" --local))" \
        '--yes[Do not ask for confirmation]' \
        $commonOpts &&
        ret=0
      ;;
    update)
      _arguments \
        "1: :($(sdkvm list --local))" \
        '--no-use[Do not enable the version after installing]' \
        '--no-save[Do not save the version as the default after installing]' \
        $commonOpts &&
        ret=0
      ;;
    enable)
      _arguments \
        "1: :($(sdkvm list --local))" \
        "2: :($(sdkvm list "$words[2]" --local))" \
        '--save[Enable SDK version for next sessions]' \
        $commonOpts &&
        ret=0
      ;;
    disable)
      _arguments \
        "1: :($(sdkvm list --local))" \
        "2: :($(sdkvm list "$words[2]" --local))" \
        '--save[Disable SDK version for next sessions]' \
        $commonOpts &&
        ret=0
      ;;
    *)
      ((ret)) && _message 'no more arguments'
      ;;
    esac
    ;;
  esac
  return ret
}
