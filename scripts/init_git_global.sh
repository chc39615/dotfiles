#!/bin/bash

## ===============================================================
## Using libsecret on Linux requires installing a compatible 
## secrets storage backend (e.g., gnome-keyring, keepassxc, or kwallet)
## to securely store passwords.
## 
## After installing the necessary packages, you may need to create 
## a storage database within the chosen application to store the credentials.
## 
## For more information, refer to the Arch Wiki:
## [Arch Wiki](https://wiki.archlinuxcn.org/zh-tw/Git#%E5%AE%89%E8%A3%85)
## ===============================================================


# Default values
DEFAULT_EMAIL="yaoyuan@doinlab.com"
DEFAULT_NAME="yaoyuan"
DEFAULT_CREDENTIAL_HELPER="cache"

# Detect the operating system for secure storage
detect_secure_store() {
    case "$OSTYPE" in
        darwin*) echo "osxkeychain" ;;  # macOS
        linux*) echo "libsecret" ;;     # Linux
        msys*|cygwin*|win*) echo "manager-core" ;;  # Windows
        *) echo "$DEFAULT_CREDENTIAL_HELPER" ;;     # Fallback
    esac
}

# Prompt user for Git email
read -p "Enter your Git email (default: $DEFAULT_EMAIL): " email
email=${email:-$DEFAULT_EMAIL}

# Prompt user for Git name
read -p "Enter your Git name (default: $DEFAULT_NAME): " name
name=${name:-$DEFAULT_NAME}

# Prompt user for autosetuprebase setting
read -p "Set autosetuprebase to 'always'? (y/n, default: y): " set_rebase
set_rebase=${set_rebase:-y}

# Determine the secure store method based on the operating system
secure_store=$(detect_secure_store)

# Prompt user to select a credential helper
echo "Choose a credential helper method:"
echo "1) cache (temporary storage)"
echo "2) store (persistent plain text storage)"
echo "3) secure store ($secure_store)"
read -p "Enter your choice (1-3, default: 3): " helper_choice

case "$helper_choice" in
    1) credential_helper="cache" ;;
    2) credential_helper="store" ;;
    3|*) credential_helper="$secure_store" ;;
esac

# Set Git global configuration
echo "Setting Git global configuration..."
git config --global user.email "$email"
git config --global user.name "$name"

if [[ "$set_rebase" =~ ^[Yy]$ ]]; then
    git config --global branch.autosetuprebase always
    echo "autosetuprebase has been set to 'always'."
else
    echo "autosetuprebase setting skipped."
fi

# Configure credential helper
echo "Configuring Git credential helper to '$credential_helper'..."
git config --global credential.helper "$credential_helper"

# Display the final configuration
echo "Git global configuration set:"
echo "Email: $(git config --global user.email)"
echo "Name:  $(git config --global user.name)"
if git config --global branch.autosetuprebase &> /dev/null; then
    echo "autosetuprebase: $(git config --global branch.autosetuprebase)"
fi
echo "Credential helper: $(git config --global credential.helper)"

echo "Git configuration complete!"

