#!/usr/bin/env bash

BASHRC="$HOME/.bashrc"

# Fix the path to the dotfiles folder
DOTFILES_DIR="$HOME/dotfiles"

# Source the utils.sh file to use the install_package function
source "$DOTFILES_DIR/scripts/utils.sh"

# Commands to be added
PYENV_LINES=(
    'eval "$(fzf --bash)"'
)

# Add each line to ~/.bashrc if missing
for line in "${PYENV_LINES[@]}"; do
    add_to_bashrc "$line"
done

# Reload ~/.bashrc
source "$BASHRC"
echo "fzf environmint variable setup is complete."
