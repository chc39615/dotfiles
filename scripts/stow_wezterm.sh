#!/usr/bin/env bash

# Fix the path to the dotfiles folder
DOTFILES_DIR="$HOME/dotfiles"

# Directory for wezterm dotfiles
SOURCE_DIR="$DOTFILES_DIR/wezterm"

# Target directory (.config)
TARGET_DIR="$HOME/.config/wezterm"

# Source the utils script
source "$DOTFILES_DIR/scripts/utils.sh"

# run the stow function for the neovim config
stow_dotfiles "$SOURCE_DIR" "$TARGET_DIR"
