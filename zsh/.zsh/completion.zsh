autoload -Uz compinit
compinit

# 1. Enable case-insensitive tab completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# 2. Disable zsh's own menu so fzf-tab shows the completion list
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# 3. 補全選單分類與顏色化（與 ls 顏色一致）
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
