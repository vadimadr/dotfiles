 if [[ ! $TERM =~ screen && -z "$NO_TMUX" ]]; then
     exec tmux
 fi

# Set up the prompt

# autoload -Uz promptinit
# promptinit
# prompt adam1
autoload -U colors && colors

setopt histignorealldups sharehistory

# Use emacs keybindings even if our EDITOR is set to vi
bindkey -e

# Keep 1000 lines of history within the shell and save it to ~/.zsh_history:
HISTSIZE=30000
SAVEHIST=30000
HISTFILE=~/.zsh_history

# completion modules
zmodload -a zsh/stat stat                
zmodload -a zsh/zpty zpty               
zmodload -a zsh/zprof zprof              
zmodload -ap zsh/mapfile mapfile   
setopt histignorealldups sharehistory

# prevent zsh to print an error when no match can be found (allows to type commands w/o "")
unsetopt nomatch

# Use emacs keybindings even if our EDITOR is set to vi
bindkey -e

# do not try to correct all arguments in line
unsetopt correct_all

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:kill:*' force-list always
zstyle ':completion:*:*:kill:*:processes' list-colors "=(#b) #([0-9]#)*=$color[cyan]=$color[red]"
zstyle ':completion:*:*:kill:*:processes' command 'ps --forest -A -o pid,user,cmd'
zstyle ':completion:*:processes-names' command 'ps axho command' 
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*::::' completer _expand _complete _correct _ignored _approximate
zstyle -e ':completion:*:approximate:*' max-errors 'reply=( $(( ($#PREFIX+$#SUFFIX)/3 )) numeric )'
zstyle ':completion:*:expand:*' tag-order all-expansions
zstyle ':completion:*' verbose yes
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:options' auto-description '%d'
zstyle ':completion:*:descriptions' format '> %B%d%b'
zstyle ':completion:*:messages' format '> %d'
zstyle ':completion:*:warnings' format '> Ошибка: нет совпадений для: %d'
zstyle ':completion:*:corrections' format '> %B%d (число ошибок: %e)%b'
zstyle ':completion:*:correct:*' insert-unambiguous true
zstyle ':completion:*:correct:*' original true
zstyle ':completion:*:correct:*' prompt 'исправить на:'
zstyle ':completion:*' prompt 'Исправить (число ошибок: %e) > '
zstyle ':completion:*' group-name ''
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' 'r:|[._-]=** r:|=**' 'l:|=* r:|=*'
zstyle ':completion:*' match-original both
zstyle ':completion:*:matches' group 'yes'
zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters
zstyle ':completion:*:*:(^rm):*:*files' ignored-patterns '*?.o' '*?.c~''*?.old' '*?.pro'
zstyle ':completion:*:rm:*' ignore-line yes
zstyle ':completion:*:functions' ignored-patterns '_*'
zstyle ':completion:*:incremental:*' completer _complete _correct
zstyle ':completion:*:predict:*' completer _complete
zstyle ':mime:*' x-browsers firefox rekonq google-chrome konqueror chromium-browser
zstyle ':mime:*' tty-browsers w3m elinks links lynx
zstyle -e ':completion:*' hosts 'reply=($myhosts)'
zstyle ':completion:*' insert-tab true
zstyle ':completion:*' select-prompt '%SСтрока: %LЭлемент: %M[%p]%s'
zstyle ':completion:*' list-prompt '%SТекущее положение: %p%s'
zstyle ':completion:*' sort true
zstyle ':completion:*' file-sort name
zstyle ':completion:*' keep-prefix changed
zstyle ':completion:*:man:*' separate-sections true
zstyle ':completion:*:history-words' stop yes
zstyle ':completion:*:history-words' remove-all-dups yes
zstyle ':completion:*:history-words' list false
zstyle ':completion:*:history-words' menu yes select
zstyle ':completion:*' old-menu true
zstyle ':completion:*' original true
zstyle ':completion:*' substitute 1
zstyle ':completion:*' use-compctl true
zstyle ':completion:*' word true
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*:(ssh|scp|ftp):*' hosts $hosts
zstyle ':completion:*:(ssh|scp|ftp):*' users $users
zstyle ':completion:*:complete:-command-::commands' ignored-patterns '*\~'
zstyle ':completion:*:*:*:users' ignored-patterns adm apache bin daemon games gdm halt ident junkbust lp mail mailnull named news nfsnobody nobody nscd ntp operator pcap postgres radvd rpc rpcuser rpm shutdown squid sshd sync uucp vcsa xfs


zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# Keep 1000 lines of history within the shell and save it to ~/.zsh_history:
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.zsh_history

# Use modern completion system
autoload -Uz compinit
compinit

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# handle <C-S> in vim
stty -ixon

# load plugins
for plugin in ~/.zshrc.d/plugins/*.zsh; do
  if [[ -r $plugin ]]; then
    source $plugin
  else
    print "can not load plugin $plugin"
  fi
done

for dir in ~/.zshrc.d/plugins/*; do

  if [[ -f $dir ]]; then
    continue
  fi

  dirname=${dir:t}

  for pluginfile in $dir/$dirname.{plugin.zsh,zsh}; do
    if [[ -r $pluginfile ]]; then
      source $pluginfile
      continue 2
    fi
  done

  print "can not load plugin from '$dir'" >&2
done

# load other configs 
for file in ~/.zshrc.d/*; do
  if [[ -r $file && "$file" !=  *.old ]]; then
    source $file
  fi
done

BASE16_SHELL=$HOME/.config/base16-shell/

EDITOR=vim

## init oh-my-zsh
export ZSH=$HOME/oh-my-zsh
ZSH_THEME="fishy" # prompt style
DISABLE_AUTO_UPDATE="true" 
plugins=(git z dircycle zsh-completions)
source $ZSH/oh-my-zsh.sh

autoload -Uz compinit
compinit

. ~/oh-my-zsh/plugins/z/z.sh 
setopt magic_equal_subst

export WORKON_HOME=$HOME/.virtualenvs
export VIRTUALENVWRAPPER_SCRIPT=$HOME/.local/bin/virtualenvwrapper.sh
export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3
export VIRTUALENVWRAPPER_VIRTUALENV=$HOME/.local/bin/virtualenv
source $HOME/.local/bin/virtualenvwrapper_lazy.sh

export CUDA_HOME=/usr/local/cuda
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:/usr/local/cuda/lib64"


export NVM_DIR="/home/vadim/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
workon py36
eval $(thefuck --alias)