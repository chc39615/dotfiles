# antidote plugin manager — plugin list lives in ~/.zsh/zsh_plugins.txt
[[ -d ~/.antidote ]] || git clone --depth=1 -c core.autocrlf=false https://github.com/mattmc3/antidote.git ~/.antidote

# zsh-vi-mode settings must be set before the plugin loads
ZVM_SYSTEM_CLIPBOARD_ENABLED=true

source ~/.antidote/antidote.zsh
# static file goes to $HOME, outside the dotfiles repo
antidote load ~/.zsh/zsh_plugins.txt ~/.zsh_plugins.zsh

# Apply extra configurations (Only after antidote load)
source ~/.zsh/plugins/auto-suggestion.zsh
