# key bindings

zmodload zsh/terminfo

# search in history using up and down arrow keys
bindkey  "$terminfo[kcuu1]" history-beginning-search-backward
bindkey  "$terminfo[kcud1]" history-beginning-search-forward
bindkey  "^[[A" history-beginning-search-backward
bindkey  "^[[B" history-beginning-search-forward

# ctrl back arrow to jump one word backward 
bindkey '^[[1;5C' emacs-forward-word
bindkey '^[[1;5D' emacs-backward-word

# ctrl del to delete word after cursor
bindkey '^[[3;5~' kill-word

# cttl f to open file manager
bindkey -s '^f' 'r^M'
