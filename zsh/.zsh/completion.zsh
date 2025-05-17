# The following lines were added by compinstall
zstyle :compinstall filename '/home/cody/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

# Enable case-insensitive (and partial) tab completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
