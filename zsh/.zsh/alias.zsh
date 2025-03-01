## get rid of command not found ##
alias cd..='cd ..'
 
## a quick way to get out of current directory ##
alias ..='cd ..'
alias ...='cd ../../../'
alias ....='cd ../../../../'
alias .....='cd ../../../../'
alias .4='cd ../../../../'
alias .5='cd ../../../../..'

## Colorize the grep command output for ease of use (good for log files)##
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'


# create directory recursive
alias mkdir='mkdir -pv'

alias path='echo -e ${PATH//:/\\n}'
alias now='date +"%Y-%m-%d %T (%a)" | tr "[:lower:]" "[:upper:]"'
alias nowtime='date +%T'
alias nowdate='date +"%Y-%m-%d"'


# do not delete / or prompt if deleting more than 3 files at a time #
alias rm='rm -i'
 
# confirmation #
alias mv='mv -i'
alias cp='cp -i'
alias ln='ln -i'
 
## set some other defaults ##
alias df='df -H'
alias du='du -ch'
