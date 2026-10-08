# antidote plugin manager — plugin list lives in ~/.zsh/zsh_plugins.txt
[[ -d ~/.antidote ]] || git clone --depth=1 -c core.autocrlf=false https://github.com/mattmc3/antidote.git ~/.antidote

# plugin settings — set before load (some options are only read when a plugin initializes)
# =========================================================================================
# auto-suggestion
ZSH_AUTOSUGGEST_STRATEGY=(history completion)


# fzf-tab
# zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always --icons $realpath'
# zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# 同時支援 cd 和 zoxide
# zstyle ':fzf-tab:complete:(cd|__zoxide_z):*' fzf-preview 'eza -1 --color=always --icons "$realpath"'

# 使用 bat (帶有語法高亮的 cat) 來預覽檔案，如果是資料夾就用 eza
# zstyle ':fzf-tab:complete:*' fzf-preview '[[ -d $realpath ]] && eza -1 --color=always "$realpath" || bat --color=always --style=numbers "$realpath"'


# 1. 關鍵設定：強迫 Zsh 補全系統把 zoxide 的輸出當作實體路徑（這樣 $realpath 才會生效）
zstyle ':fzf-tab:complete:(__zoxide_z|__zoxide_zi):*' file-path 'true'

# 2. 您原本的優化預覽（加上 file-path 後，這裡的 $realpath 就能 100% 抓到絕對路徑）
zstyle ':fzf-tab:complete:(__zoxide_z|__zoxide_zi):*' fzf-preview 'eza -1 --color=always "$realpath"'

# 3. 如果您希望連「空格」都不想打，直接 z <關鍵字><Tab> 就撈資料庫，再加這行：
zstyle ':fzf-tab:complete:(__zoxide_z|__zoxide_zi):*' fake-compadd '$(zoxide query -l)'

# =========================================================================================

source ~/.antidote/antidote.zsh
# static file goes to $HOME, outside the dotfiles repo
antidote load ~/.zsh/zsh_plugins.txt ~/.zsh_plugins.zsh
