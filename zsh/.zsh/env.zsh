# history
HISTFILE=~/.histfile
HISTSIZE=100000
SAVEHIST=100000
setopt EXTENDED_HISTORY       # save timestamp + duration with each command
setopt SHARE_HISTORY          # write immediately, and all tabs/panes see each other's commands
setopt HIST_IGNORE_ALL_DUPS   # re-running a command removes its older copy
setopt HIST_IGNORE_SPACE      # a command starting with a space isn't saved (for secrets)
setopt HIST_REDUCE_BLANKS     # trim extra spaces before saving

# don't write commands that look like they contain secrets to ~/.histfile
# (return 2 = keep in this shell's memory for ↑, but never write to the file)
_hist_skip_secrets() {
  setopt localoptions extendedglob
  [[ $1 == (#i)*(password|passwd|token|secret|api[_-]#key|bearer)* ]] && return 2
  return 0
}
autoload -Uz add-zsh-hook
add-zsh-hook zshaddhistory _hist_skip_secrets

# set locale
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# set default editor
export VISUAL=nvim
export EDITOR=nvim

# add "$HOME/.local/bin/" to PATH
. "$HOME/.local/bin/env"

# Use bat as man pager only if it's installed
command -v bat >/dev/null && export MANPAGER="sh -c 'col -b | bat -l man -p'"
# man outputs the page with ^H overstrike formatting
# col -b converts ^H sequences → proper ANSI escape codes (or removes them if you prefer plain)
# bat -l man -p receives clean input, applies nice syntax highlighting, and displays nothing but the actual text
