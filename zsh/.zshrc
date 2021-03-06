# Start tmux
if [[ ! $TERM =~ screen && -z "$NO_TMUX" ]]; then
    exec tmux
fi

# directory where additional config files are stored
ZSHRCD=$HOME/.zshrc.d

# default editor
EDITOR=vim
VEDITOR=code

# Setup zsh history
HISTSIZE=500000
SAVEHIST=$HISTSIZE
HISTFILE=~/.zsh_history
# remove blanks from history 
setopt histreduceblanks
# do not save dublicates in history
setopt histignorealldups
# share history between terminals
setopt sharehistory
# Automatically use menu completion after the second consecutive request for completion
setopt automenu

# auto push directories to dir stack while cding
setopt auto_pushd
setopt pushd_ignore_dups
setopt pushdminus

# Use emacs keybindings even if our EDITOR is set to vi
bindkey -e

# prevent zsh to print an error when no match can be found (allows to type commands w/o "")
# allows to run commands without escaping glob symbols
unsetopt nomatch
setopt no_nomatch 

# auto suggest to correct typoed commands
setopt correct

# do not try to correct all arguments in line
unsetopt correct_all

# Substitute ~ in cli args
setopt magic_equal_subst

# handle <C-S> in vim
stty -ixon

eval "$(dircolors -b)"

# Setup default browsers
zstyle ':mime:*' x-browsers google-chrome firefox rekonq konqueror chromium-browser
zstyle ':mime:*' tty-browsers w3m elinks links lynx

# Use antigen plugin manager
# It uses caching to speed up initialization
# To install run: 
# curl -L git.io/antigen > $ZSHRCD/antigen/antigen.zsh
ANTIGEN_BUNDLES=$ZSHRCD/antigen-bundles
source $ZSHRCD/antigen/antigen.zsh

# Enable logging to debug errors, if any:
# ANTIGEN_LOG=$ZSHRCD/antigen.log
# ANTIGEN_DEBUG_LOG=$ZSHRCD/antigen_debug.log

# Load oh-my-zsh framework
antigen use oh-my-zsh

# Suggest package to install missing commands
antigen bundle command-not-found
# iterate through dir stack using keybinds (C-up/C-down)
antigen bundle dircycle
# Git related aliases
antigen bundle git
# Tmux aliases
ZSH_TMUX_AUTOSTART=false
ZSH_TMUX_AUTOCONNECT=false
antigen bundle tmux
# pip completions
antigen bundle pip
# allows to run google ... in terminal!
antigen bundle web-search
# needed for pure theme
antigen bundle mafredri/zsh-async
# suggest while you type
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_USE_ASYNC=true
antigen bundle zsh-users/zsh-autosuggestions
# additional completions
antigen bundle zsh-users/zsh-completions
# Color differentiation in shell!
antigen bundle zdharma/fast-syntax-highlighting
# antigen bundle zsh-users/zsh-syntax-highlighting

# Minimalistic theme (prompt) with a lot of useful information:
PURE_PROMPT_SYMBOL="$"
# Threshold after which execution time will be displayed for executed command
PURE_CMD_MAX_EXEC_TIME=0.5
antigen theme https://github.com/sindresorhus/pure 

# Another great prompt theme
# SPACESHIP_EXIT_CODE_SHOW=true
# antigen theme https://github.com/denysdovhan/spaceship-zsh-theme spaceship

# Type part of the command and navigate with up / down arrows
antigen bundle zsh-users/zsh-history-substring-search

antigen apply

# Some completion settings
source $ZSHRCD/zstyles.zsh
# My custom aliases & snippets
# Load after antigen setup to overwrite plugin aliases
source $ZSHRCD/aliases.zsh
# My custom shortcuts
source $ZSHRCD/bindkeys.zsh
source $ZSHRCD/colors.zsh


# Setup virtualenv wrapper
WORKON_HOME=$HOME/.virtualenvs
VIRTUALENVWRAPPER_SCRIPT=$HOME/.local/bin/virtualenvwrapper.sh
VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3
VIRTUALENVWRAPPER_VIRTUALENV=$HOME/.local/bin/virtualenv
source $HOME/.local/bin/virtualenvwrapper_lazy.sh

# Init default virtual env
# Do not execute python scripts at zsh init! Init env manually
DEFAULT_VIRTUAL_ENV=py36
PATH="$WORKON_HOME/$DEFAULT_VIRTUAL_ENV/bin:$PATH"
VIRTUALENVWRAPPER_PROJECT_FILENAME=.project
VIRTUALENVWRAPPER_WORKON_CD=1
VIRTUALENVWRAPPER_HOOK_DIR=/home/vadim/.virtualenvs
VIRTUAL_ENV=/home/vadim/.virtualenvs/py36

CUDA_HOME=/usr/local/cuda
LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:/usr/local/cuda/lib64"

# Setup node version manager
# export NVM_DIR="/home/vadim/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

# Enable fuzzy finder
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh