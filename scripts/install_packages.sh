#!/usr/bin/env bash

# Fix the path to the dotfiles folder
DOTFILES_DIR="$HOME/dotfiles"

# Source the utils.sh file to use the install_package function
source "$DOTFILES_DIR/scripts/utils.sh"

# install lazygit
if ! install_package lazygit; then
    cecho "Failing back to custom Lazygit installation..." "$YELLOW"


    read -p "Do you want to manual install Lazygit? (y/n): " CHOICE
    if [[ "$CHOICE" != "y" && "$CHOICE" != "Y" ]]; then
        echo -e "${YELLOW}Skipping installation of Lazygit.${NC}"
        echo "------------------------------------------------------------"
    else
        LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*')
        curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
        tar xf lazygit.tar.gz lazygit
        sudo install lazygit -D -t /usr/local/bin/
        rm lazygit.tar.gz
    fi
    cecho "Lazygit installed successfully via fallback method. " "$GREEN"
fi

# access SAMBA shares
install_package cifs-utils

# pyenv
# install_package pyenv
# setup the pyenv environment variables
# install_package tk   # dependency for pyenv install python

# starship
if ! install_package starship; then
    cecho "Failing back to custom Lazygit installation..." "$YELLOW"

    read -p "Do you want to manual install starship? (y/n): " CHOICE
    if [[ "$CHOICE" != "y" && "$CHOICE" != "Y" ]]; then
        echo -e "${YELLOW}Skipping installation of starship.${NC}"
        echo "------------------------------------------------------------"
    else
        curl -sS https://starship.rs/install.sh | sh
    fi
fi


# Zoxide
install_package zoxide

# Fzf
install_package fzf

# yazi
if ! install_package yazi; then
    cecho "Failing back to custom Yazi installation..." "$YELLOW"

    read -p "Do you want to manual install Yazi? (y/n): " CHOICE
    if [[ "$CHOICE" != "y" && "$CHOICE" != "Y" ]]; then
        echo -e "${YELLOW}Skipping installation of Yazi.${NC}"
        echo "------------------------------------------------------------"
    else
        YAZI_VERSION=$(curl -s "https://api.github.com/repos/sxyazi/yazi/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*')
        curl -Lo yazi-x86_64-unknown-linux-gnu "https://github.com/sxyazi/yazi/releases/download/v${YAZI_VERSION}/yazi-x86_64-unknown-linux-gnu.zip"
        unzip yazi-x86_64-unknown-linux-gnu
        cp yazi-x86_64-unknown-linux-gnu/yazi ~/.local/bin/
        cp yazi-x86_64-unknown-linux-gnu/ya ~/.local/bin/

        rm -rf yazi-x86_64-unknown-linux-gnu
        rm yazi-x86_64-unknown-linux-gnu
    fi

    cecho "Yazi installed successfully via fallback method. " "$GREEN"
fi 

# eza
install_package eza

# install c compiler
install_ccompiler
