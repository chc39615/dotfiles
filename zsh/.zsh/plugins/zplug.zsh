if [[ "$(uname)" == "Darwin" ]]; then
    # zplug mac
  export ZPLUG_HOME=/opt/homebrew/opt/zplug
else
  export ZPLUG_HOME=$HOME/.zplug
fi


source $ZPLUG_HOME/init.zsh

zplug "zsh-users/zsh-autosuggestions", use:"*.zsh", defer:3
zplug "zsh-users/zsh-syntax-highlighting", defer:2

if ! zplug check; then
    echo "Installing missing plugins..."
    zplug install
fi

# Initialize plugins
zplug load

# Apply extra configurations (Only after zplug load)
source ~/.zsh/plugins/auto-suggestion.zsh
source ~/.zsh/plugins/syntax-highlighting.zsh
