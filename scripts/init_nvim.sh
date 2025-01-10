#!/bin/bash


# Fix the path to the dotfiles folder
DOTFILES_DIR="$HOME/dotfiles"

# Source the utils.sh file to use the install_package function
source "$DOTFILES_DIR/scripts/utils.sh"

# for clipboard support
install_package xclip

# install mason dependency
install_package git
install_package curl
install_package wget
install_package unzip
install_package tar
install_package gzip

# install pyright compiler
install_package npm
