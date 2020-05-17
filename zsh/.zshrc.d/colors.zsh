# Colors and promt

# Base16 Shell
BASE16_SHELL="$HOME/.config/base16-shell/base16-default.dark.sh"
# [[ -s $BASE16_SHELL ]] && source $BASE16_SHELL

# PROMPT="%{$fg_bold[green]%}%n@%m %{$fg_no_bold[blue]%}%~ $ %{$reset_color%}% "

# colored less and man

export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

# COLORIZE suggest prompt
SPROMPT='zsh: correct %F{1}%R%f to %F{2}%r%f [%F{2}y%fes %F{1}n%fo %F{4}e%fdit %F{4}a%fbort]?'