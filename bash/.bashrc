#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '

# my alias
# --- navigate ---
alias ..="cd .."
alias .2="cd ../../"
alias .3="cd ../../../"
alias .4="cd ../../../../"
alias .5="cd ../../../../../"

# --- file management ---
alias mv="mv -i"
alias rm="rm -i"
alias cp="cp -i"
alias ln="ln -i"
alias mkdir="mkdir -pv"

# --- environment variable & system/disk info ---
alias genv="printenv | grep -i"
alias path="echo -e ${PATH//:/\\n}"
alias now='date +"%T"'
alias nowd='date +"%Y-%m-%d"'
alias df='df -h'
alias dusage='du -sh * 2>/dev/null'

# initial tools
eval "$(starship init bash)"
eval "$(zoxide init bash)"
eval "$(fzf --bash)"

