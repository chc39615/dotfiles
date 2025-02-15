# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
unsetopt beep
bindkey -v
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/cody/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall
#
#
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
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"

eval "$(pyenv init - zsh)"
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
eval "$(fzf --zsh)"

# zplug
source ~/.zplug/init.zsh
zplug load
