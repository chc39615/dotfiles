# antidote plugin manager — plugin list lives in ~/.zsh/zsh_plugins.txt
[[ -d ~/.antidote ]] || git clone --depth=1 -c core.autocrlf=false https://github.com/mattmc3/antidote.git ~/.antidote

# plugin settings — set before load (some options are only read when a plugin initializes)
# =========================================================================================
# zsh-vim-mode
ZVM_SYSTEM_CLIPBOARD_ENABLED=true

# auto-suggestion
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
# =========================================================================================

source ~/.antidote/antidote.zsh
# static file goes to $HOME, outside the dotfiles repo
antidote load ~/.zsh/zsh_plugins.txt ~/.zsh_plugins.zsh
