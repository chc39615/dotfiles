install_package() {
    PACKAGE_NAME=$1

    if [[ -z "$PACKAGE_NAME" ]]; then
        echo "Error: No package name provided."
        echo "Usage: install_package <package_name>"
        return 1
    fi

    echo "Checking if $PACKAGE_NAME is already installed..."

    # Determine the installed version using pacman if available
    if command -v pacman &> /dev/null; then
        INSTALLED_VERSION=$(pacman -Qi "$PACKAGE_NAME" 2>/dev/null | grep Version | awk '{print $3}')
    else
        INSTALLED_VERSION="not available for this OS"
    fi

    # Check if pacman -Qi failed or INSTALLED_VERSION is empty
    if [[ -z "$INSTALLED_VERSION" ]]; then
        INSTALLED_VERSION="not installed"
    fi

    if [[ "$INSTALLED_VERSION" != "not installed" ]]; then
        echo "$PACKAGE_NAME is already installed."
        echo "Installed version: $INSTALLED_VERSION"
    else
        echo "$PACKAGE_NAME is not installed."
    fi

    # Get the repository version of the package
    echo "Checking the repository version of $PACKAGE_NAME..."
    if command -v pacman &> /dev/null; then
        REPO_VERSION=$(pacman -Si "$PACKAGE_NAME" 2>/dev/null | grep Version | awk '{print $3}' || echo "Repository version not available.")
    else
        REPO_VERSION="not available for this OS"
    fi

    echo "Repository version: $REPO_VERSION"

    # Ask the user whether to proceed with installation
    read -p "Do you want to install/reinstall $PACKAGE_NAME? (y/n): " CHOICE
    if [[ "$CHOICE" != "y" && "$CHOICE" != "Y" ]]; then
        echo "Skipping installation of $PACKAGE_NAME."
        echo "------------------------------------------------------------"
        return 0
    fi

    echo "Starting installation of $PACKAGE_NAME..."

    # Install the package using pacman if available
    if command -v pacman &> /dev/null; then
        sudo pacman -Syu --noconfirm "$PACKAGE_NAME"
    else
        echo "Unsupported package manager for this OS. Please install $PACKAGE_NAME manually."
        echo "------------------------------------------------------------"
        return 1
    fi

    # Verify installation
    if pacman -Qi "$PACKAGE_NAME" &> /dev/null; then
        INSTALLED_VERSION=$(pacman -Qi "$PACKAGE_NAME" | grep Version | awk '{print $3}')
        echo "$PACKAGE_NAME installed successfully! Version: $INSTALLED_VERSION"
        echo "------------------------------------------------------------"
    else
        echo "Installation failed. Please try installing $PACKAGE_NAME manually."
        echo "------------------------------------------------------------"
        return 1
    fi

}



# Function to remove files or directories from target folder
remove_existing_files() {
    local stow_folder=$1
    local target_folder=$2

    # Loop through all files and directories in the stow folder
    for file in "$stow_folder"/{*,.*}; do
        [[ "$(basename "$file")" == "." || "$(basename "$file")" == ".." ]] && continue
        # Check if the item is a file or directory
        if [[ -f "$file" || -d "$file" ]]; then
            local filename=$(basename "$file")
            local target_file="$target_folder/$filename"

            if [[ -e "$target_file" ]]; then
                echo "Removing $target_file from $target_folder..."
                rm -rf "$target_file"
                if [[ $? -eq 0 ]]; then
                    echo "$target_file removed successfully."
                else
                    echo "Failed to remove $target_file."
                fi
            else
                echo "$target_file does not exist in $target_folder. Skipping removal."
            fi
        fi
    done
}

# Function to move existing files to backup from the target folder
move_existing_files_to_backup() {
    local stow_folder=$1
    local target_folder=$2

    # Automatically generate the backup directory based on the stow folder
    local backup_folder="$HOME/dotfiles/backup/$(basename "$stow_folder")"

    # Create backup folder if it does not exist
    mkdir -p "$backup_folder"

    # Loop through all files and directories in the stow folder
    for file in "$stow_folder"/{*,.*}; do
        [[ "$(basename "$file")" == "." || "$(basename "$file")" == ".." ]] && continue

        # Check if the item is a file or directory
        if [[ -f "$file" || -d "$file" ]]; then
            local filename=$(basename "$file")
            local target_file="$target_folder/$filename"
            local backup_file="$backup_folder/$filename"

            if [[ -e "$target_file" ]]; then
                echo "Moving $target_file to $backup_file..."
                mv -n "$target_file" "$backup_file"  # Move without overwriting
                if [[ $? -eq 0 ]]; then
                    echo "$target_file moved to $backup_file successfully."
                else
                    echo "Failed to move $target_file."
                fi
            else
                echo "$target_file does not exist in $target_folder. Skipping move."
            fi
        fi
    done
}


# Function to use stow to symlink files from the stow folder to the target folder
stow_dotfiles() {
    local stow_folder=$1
    local target_folder=$2

    # Check if the stow folder exists
    if [[ ! -d "$stow_folder" ]]; then
        echo "Stow folder ($stow_folder) does not exist."
        exit 1
    fi

    # Remove existing files in the target directory before using stow
    move_existing_files_to_backup "$stow_folder" "$target_folder"

    # Use stow to create symlinks in the target directory
    echo "Creating symlinks from $stow_folder to $target_folder..."
    cd "$stow_folder" && stow -t "$target_folder" .

    # Check if stow succeeded
    if [[ $? -eq 0 ]]; then
        echo "Symlinks created successfully from $stow_folder to $target_folder."
    else
        echo "Failed to create symlinks. Please check for errors."
        exit 1
    fi
}
