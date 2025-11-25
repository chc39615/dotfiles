#!/usr/bin/env bash

# Fix the path to the dotfiles folder
DOTFILES_DIR="$HOME/dotfiles"

# Source the utils.sh file to use the install_package function
source "$DOTFILES_DIR/scripts/utils.sh"

# use the install_package function to install stow
install_package zsh

# change default shell
chsh -s /usr/bin/zsh
