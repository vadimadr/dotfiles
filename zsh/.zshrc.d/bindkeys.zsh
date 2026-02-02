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

# Kitty / Cursor-style: Opt+Backspace, Opt+Left/Right, Opt+Delete
# (Kitty sends these sequences; Cmd+Backspace/Left/Right use Ctrl+U/A/E which are default)
bindkey '\e^?'   backward-kill-word   # Opt+Backspace
bindkey '\e[1;3D' backward-word       # Opt+Left
bindkey '\e[1;3C' forward-word        # Opt+Right
bindkey '\e[3;3~' kill-word           # Opt+Delete (forward)

# use crtl + up / ctrl + down to iterate through dir stack (oh-my-zsh/dircycle)
bindkey '^[[1;5A' insert-cycledleft
bindkey '^[[1;5B' insert-cycledright

# cttl f to open file manager
bindkey -s '^f' 'r^M'
