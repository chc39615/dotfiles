# Source the base configuration
source ~/.zsh/env.zsh
source ~/.zsh/options.zsh
source ~/.zsh/completion.zsh
source ~/.zsh/alias.zsh


# Source plugin configurations
source ~/.zsh/plugins/antidote.zsh
source ~/.zsh/plugins/pyenv.zsh
source ~/.zsh/plugins/zoxide.zsh
source ~/.zsh/plugins/startship.zsh
# zsh-vi-mode resets keybindings on init, so fzf (Ctrl-R/Ctrl-T) must bind after it
zvm_after_init_commands+=('source ~/.zsh/plugins/fzf.zsh')
source ~/.zsh/plugins/eza.zsh

