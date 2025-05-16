_EZA_PARAMS=('--git' '--group' '--group-directories-first' '--time-style=long-iso' '--color-scale=all' '--icons' '--header')

alias ls='eza $_EZA_PARAMS'
alias tree='eza --tree $eza_params'
alias l='eza $_EZA_PARAMS -l'
alias lh='eza $_EZA_PARAMS -lha'
