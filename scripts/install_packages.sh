#!/bin/bash

# Fix the path to the dotfiles folder
DOTFILES_DIR="$HOME/dotfiles"

# Source the utils.sh file to use the install_package function
source "$DOTFILES_DIR/scripts/utils.sh"

# install lazygit
install_package lazygit
