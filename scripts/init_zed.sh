#!/usr/bin/env bash

# Fix the path to the dotfiles folder
DOTFILES_DIR="$HOME/dotfiles"

# Source the utils.sh file for the color definitions
source "$DOTFILES_DIR/scripts/utils.sh"

# install zed if missing (install_package only covers pacman/apt)
if ! command -v zed >/dev/null 2>&1 && ! command -v zeditor >/dev/null 2>&1; then
    case "$OSTYPE" in
        darwin*) brew install --cask zed ;;
        linux*) curl -f https://zed.dev/install.sh | sh ;;
        *) echo -e "${RED}Unsupported OS: $OSTYPE${NC}"; exit 1 ;;
    esac
fi

echo "Zed install is complete. Run stow_zed.sh to link the config."
