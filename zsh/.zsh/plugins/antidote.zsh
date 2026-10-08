# antidote plugin manager — plugin list lives in ~/.zsh/zsh_plugins.txt
[[ -d ~/.antidote ]] || git clone --depth=1 -c core.autocrlf=false https://github.com/mattmc3/antidote.git ~/.antidote

# plugin settings — set before load (some options are only read when a plugin initializes)
# =========================================================================================
# auto-suggestion
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# fzf-tab
# group headers ([files], [directories], [git branches]…); switch groups with < and >
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':fzf-tab:*' switch-group '<' '>'
# make the active group's label stand out (default is bold only; supported: bold, underline)
zstyle ':fzf-tab:*' active-group-style bold underline

# all commands (cd too): preview folders with eza, files with bat (first 200 lines)
zstyle ':fzf-tab:complete:*:*' fzf-preview '[[ -d $realpath ]] && eza -1 --color=always --icons=always "$realpath" || bat --color=always --style=numbers --decorations=always --line-range=:200 "$realpath" 2>/dev/null'

# multi-select: Ctrl-X marks an item and moves down (default Ctrl-Space is taken by macOS input-source switching)
zstyle ':fzf-tab:*' fzf-bindings 'ctrl-x:toggle+down'

# keep git branches/tags in git's own order instead of alphabetical
zstyle ':completion:*:git-checkout:*' sort false

# environment variables: show the value  (echo $PA<Tab>, export <Tab>, unset <Tab>)
zstyle ':fzf-tab:complete:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*' fzf-preview 'echo ${(P)word}'

# git: show the diff when picking files, recent commits when picking a branch/tag
zstyle ':fzf-tab:complete:git-(add|diff|restore):*' fzf-preview 'git diff --color=always -- $word'
zstyle ':fzf-tab:complete:git-(checkout|switch|log):*' fzf-preview 'git log --oneline --color=always -20 $word'

# inside tmux: open the list in a tmux popup instead of under the prompt
[[ -n $TMUX ]] && zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
# popup is sized to fit the list (tiny for short lists); force a minimum width/height (cols rows),
# automatically capped to the tmux window width and the space above/below the cursor
zstyle ':fzf-tab:*' popup-min-size 120 30


# =========================================================================================

source ~/.antidote/antidote.zsh
# static file goes to $HOME, outside the dotfiles repo
antidote load ~/.zsh/zsh_plugins.txt ~/.zsh_plugins.zsh
