# key bindings
# see keycodes via: showkey -a

# deprecated: use zsh-history-search
# search in history using up and down arrow keys
# bindkey  "^[[A" history-beginning-search-backward
# bindkey  "^[[B" history-beginning-search-forward

# ctrl back arrow to jump one word backward 
bindkey '^[[1;5C' emacs-forward-word
bindkey '^[[1;5D' emacs-backward-word

# ctrl del to delete word after cursor
bindkey '^[[3;5~' kill-word
# Ctrl+backspace = C-w
bindkey '^H' backward-kill-word

# use crtl + up / ctrl + down to iterate through dir stack (oh-my-zsh/dircycle)
bindkey '^[[1;5A' insert-cycledleft
bindkey '^[[1;5B' insert-cycledright

# cttl f to open file manager
bindkey -s '^f' 'r^M'
