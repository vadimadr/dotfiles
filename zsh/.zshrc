# has to be added at the top
# for example to correctly launch locally installed tmux

# add ~/local/bin or ~/opt/local/bin to PATH
if [[ -d $HOME/local/bin ]]; then
    _local_bin_path=$HOME/local/bin
elif [[ -d $HOME/opt/local/bin ]]; then
    _local_bin_path=$HOME/opt/local/bin
fi
if [[ -n $_local_bin_path && ! $PTAH =~ $_local_bin_path ]]; then
    export PATH="${_local_bin_path}:${PATH}"
fi
# add ~/local/lib or ~/opt/local/lib to LD_LIBRARY_PATH
if [[ -d $HOME/local/lib ]]; then
    _local_lib_path=$HOME/local/lib
elif [[ -d $HOME/opt/local/lib ]]; then
    _local_lib_path=$HOME/opt/local/lib
fi
if [[ -n $_local_lib_path && ! $LD_LIBRARY_PATH =~ $_local_lib_path ]]; then
    export LD_LIBRARY_PATH="${_local_lib_path}:${LD_LIBRARY_PATH}"
fi

# brew 
if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Start tmux
# Use oh-my-zsh/tmux instead! (solves [exited] issue)
# if [[ ! $TERM =~ screen && -z "$NO_TMUX" ]]; then
#     exec tmux
# fi

# directory where additional config files are stored
ZSHRCD=$HOME/.zshrc.d

LANG="en_US.UTF-8"

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

if [[ ! $OSTYPE =~ darwin ]]; then
    eval "$(dircolors -b)"
else;
    eval "$(gdircolors -b)"
fi

# Add snap directory to PATH
if [[ -d /snap/bin ]]; then
    export PATH="${PATH}:/snap/bin"
fi

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
antigen bundle gcloud
# Git related aliases
# antigen bundle git
# Tmux aliases
ZSH_TMUX_AUTOSTART=false
ZSH_TMUX_AUTOCONNECT=false
# antigen bundle tmux
# pip completions
antigen bundle pip

# # needed for pure theme
# antigen bundle mafredri/zsh-async
# suggest while you type
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# async autosuggest works weird
# it erases some autosuggestions set in .zshrc (like from gcloud)
# what is the purpose of having them?
ZSH_AUTOSUGGEST_USE_ASYNC=false

antigen bundle zsh-users/zsh-autosuggestions
# additional completions
antigen bundle zsh-users/zsh-completions
# Color differentiation in shell!

# Bug: Some commands can become very slow while typing! (e.g. man)
# temporary solution: disalbe chromas for slow command (slow chromas can be detected via zprof) -- fixed in newer version
# FAST_HIGHLIGHT[chroma-man]= disables chroma for man
antigen bundle zdharma-continuum/fast-syntax-highlighting
# antigen bundle zsh-users/zsh-syntax-highlighting

# Minimalistic theme (prompt) with a lot of useful information:
# PURE_PROMPT_SYMBOL="$"
# Threshold after which execution time will be displayed for executed command
# PURE_CMD_MAX_EXEC_TIME=0.5
# antigen theme sindresorhus/pure@main

# Another great prompt theme
# SPACESHIP_EXIT_CODE_SHOW=true
# antigen theme https://github.com/denysdovhan/spaceship-zsh-theme spaceship

# Type part of the command and navigate with up / down arrows
antigen bundle zsh-users/zsh-history-substring-search

antigen bundle agkozak/zsh-z

# Disable brew updates (takes ~20 minutes to update all packages recursively)
export HOMEBREW_NO_AUTO_UPDATE=1

# Some completion settings
source $ZSHRCD/zstyles.zsh
# My custom aliases & snippets
# Load after antigen setup to overwrite plugin aliases

source $ZSHRCD/aliases.zsh
# My custom shortcuts
source $ZSHRCD/bindkeys.zsh
source $ZSHRCD/colors.zsh

source $ZSHRCD/dev_env.zsh

antigen apply

source $ZSHRCD/completions.zsh

# Enable fuzzy finder
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Use starship as prompt
export STARSHIP_CONFIG="${ZSHRCD}/starship.toml"
eval "$(starship init zsh)"