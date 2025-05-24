unsetopt beep
bindkey -v


# fix 
# starship_zle-keymap-select-wrapped:1: maximum nested function level reached; increase FUNCNEST?
function zle-keymap-select {
    zle reset-prompt
}
zle -N zle-keymap-select

# Unbind common Ctrl+Arrow key sequences
bindkey -r '^[[1;5D'  # Ctrl+Left
bindkey -r '^[[1;5C'  # Ctrl+Right
bindkey -r '^[[1;5A'  # Ctrl+Up
bindkey -r '^[[1;5B'  # Ctrl+Down

bindkey -r "^[[A" # up-line-or-history
bindkey -r "^[[B" # down-line-or-history
# bindkey -r "^[[C" # vi-forward-char
# bindkey -r "^[[D" # vi-backward-char

# Alternate sequences (some terminals/tmux versions send these)
bindkey -r '^[OD'     # Sometimes Ctrl+Left
bindkey -r '^[OC'     # Sometimes Ctrl+Right
bindkey -r '^[OA'     # Sometimes Ctrl+Up
bindkey -r '^[OB'     # Sometimes Ctrl+Down

# Even more variants seen in tmux or macOS Terminal
# bindkey -r '^[1;9D'
# bindkey -r '^[1;9C'
# bindkey -r '^[1;9A'
# bindkey -r '^[1;9B'
