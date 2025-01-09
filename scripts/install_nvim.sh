#!/bin/bash

# Fix the path to the dotfiles folder
DOTFILES_DIR="$HOME/dotfiles"

# Source the utils.sh file to use the install_package function
source "$DOTFILES_DIR/scripts/utils.sh"

# install nvim
install_package neovim

# install mason dependency
install_package git
install_package curl
install_package wget
install_package unzip
install_package tar
install_package gzip
