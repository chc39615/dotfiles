#!/bin/bash

# Fix the path to the dotfiles folder
DOTFILES_DIR="$HOME/dotfiles"

# Source the utils.sh file to use the install_package function
source "$DOTFILES_DIR/scripts/utils.sh"

# install lazygit
install_package lazygit

# access SAMBA shares
install_package cifs-utils

# pyenv
install_package pyenv
# setup the pyenv environment variables
install_package tk   # dependency for pyenv install python

# starship
install_package starship

# Zoxide
install_package zoxide

# Fzf
install_package fzf
