unsetopt beep
# vi mode is handled by the zsh-vi-mode plugin (~/.zsh/zsh_plugins.txt)

# fix
# starship_zle-keymap-select-wrapped:1: maximum nested function level reached; increase FUNCNEST?
function zle-keymap-select {
    zle reset-prompt
}
zle -N zle-keymap-select
