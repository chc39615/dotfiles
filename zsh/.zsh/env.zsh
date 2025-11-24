# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
# End of lines configured by zsh-newuser-install

# set locale
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# add "$HOME/.local/bin/" to PATH
. "$HOME/.local/bin/env"

# Use bat as man pager only if it's installed
command -v bat >/dev/null && export MANPAGER="sh -c 'col -b | bat -l man -p'"
# man outputs the page with ^H overstrike formatting
# col -b converts ^H sequences → proper ANSI escape codes (or removes them if you prefer plain)
# bat -l man -p receives clean input, applies nice syntax highlighting, and displays nothing but the actual text
