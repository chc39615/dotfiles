#!/bin/bash

# Default values
DEFAULT_EMAIL="yaoyuan@doinlab.com"
DEFAULT_NAME="yaoyuan"

# Prompt user for email
read -p "Enter your Git email (default: $DEFAULT_EMAIL): " email
email=${email:-$DEFAULT_EMAIL} # Use default if no input

# Prompt user for name
read -p "Enter your Git name (default: $DEFAULT_NAME): " name
name=${name:-$DEFAULT_NAME} # Use default if no input

# Set Git global config
echo "Setting Git global configuration..."
git config --global user.email "$email"
git config --global user.name "$name"


# Prompt user for autosetuprebase setting
read -p "Use rebase as default merge method when pull? (y/n, default: y): " set_rebase
set_rebase=${set_rebase:-y} # Default is yes

if [[ "$set_rebase" =~ ^[Yy]$ ]]; then
    git config --global branch.autosetuprebase always
    echo "autosetuprebase has been set to 'always'."
else
    echo "autosetuprebase setting skipped."
fi

# Display the configuration
echo "Git global configuration set:"
echo "Email: $(git config --global user.email)"
echo "Name:  $(git config --global user.name)"
if git config --global branch.autosetuprebase &> /dev/null; then
    echo "autosetuprebase: $(git config --global branch.autosetuprebase)"
fi

echo "Git configuration complete!"

