#!/bin/bash

# Fix the path to the dotfiles folder
DOTFILES_DIR="$HOME/dotfiles"

# Directory for bash dotfiles
SOURCE_DIR="$DOTFILES_DIR/bash"

# Target directory (home directory)
TARGET_DIR="$HOME"

# Source the utils script
source "$DOTFILES_DIR/scripts/utils.sh"

# run the stow function for the bash dotfiles
stow_dotfiles "$SOURCE_DIR" "$TARGET_DIR"
