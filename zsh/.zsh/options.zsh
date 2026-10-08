unsetopt beep

# emacs keymap — explicit, because zsh picks vi mode when $EDITOR/$VISUAL contains "vi"
bindkey -e

# Ctrl-X Ctrl-E: edit the current command line in $EDITOR (nvim)
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line

# fix
# starship_zle-keymap-select-wrapped:1: maximum nested function level reached; increase FUNCNEST?
function zle-keymap-select {
    zle reset-prompt
}
zle -N zle-keymap-select
