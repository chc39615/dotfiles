#!/bin/bash


# Fix the path to the dotfiles folder
DOTFILES_DIR="$HOME/dotfiles"

# Directory for bash dotfiles
BASH_DIR="$DOTFILES_DIR/bash"

# Source the utils.sh file to use the install_package function
source "$DOTFILES_DIR/scripts/utils.sh"

# for clipboard support
install_package xclip

install_package neovim

