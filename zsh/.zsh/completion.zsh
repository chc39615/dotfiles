autoload -Uz compinit
compinit

# Enable case-insensitive tab completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Select from the completion list with Tab / arrow keys
zstyle ':completion:*' menu select
