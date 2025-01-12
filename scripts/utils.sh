install_package() {
    PACKAGE_NAME=$1
    INIT_FILE="$HOME/dotfiles/scripts/init_$PACKAGE_NAME.sh"

    # Define color codes
    RED="\033[0;31m"
    GREEN="\033[0;32m"
    YELLOW="\033[0;33m"
    BLUE="\033[0;34m"
    NC="\033[0m" # No color

    if [[ -z "$PACKAGE_NAME" ]]; then
        echo -e "${RED}Error: No package name provided.${NC}"
        echo -e "${YELLOW}Usage: install_package <package_name>${NC}"
        return 1
    fi

    echo -e "Checking if ${GREEN}$PACKAGE_NAME${NC} is already installed..."

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
        echo -e "${GREEN}$PACKAGE_NAME${NC} is already installed."
        echo -e "Installed version: ${YELLOW}$INSTALLED_VERSION${NC}"
    else
        echo -e "${RED}$PACKAGE_NAME is not installed.${NC}"
    fi

    # Get the repository version of the package
    echo -e "Checking the repository version of $PACKAGE_NAME..."
    if command -v pacman &> /dev/null; then
        REPO_VERSION=$(pacman -Si "$PACKAGE_NAME" 2>/dev/null | grep Version | awk '{print $3}' || echo "Repository version not available.")
    else
        REPO_VERSION="not available for this OS"
    fi

    echo -e "Repository version: ${YELLOW}$REPO_VERSION${NC}"

    if [[ "$INSTALLED_VERSION" != "not installed" ]]; then
        if [[ "$INSTALLED_VERSION" == "$REPO_VERSION" ]]; then
            echo -e "${BLUE}Installed version matches the repository version. No action required.${NC}"
            echo "------------------------------------------------------------"
            return 0
        else
            echo -e "${YELLOW}Installed version does not match the repository version.${NC}"
            read -p "Do you want to update/reinstall $PACKAGE_NAME? (y/n): " CHOICE
            if [[ "$CHOICE" != "y" && "$CHOICE" != "Y" ]]; then
                echo -e "${YELLOW}Skipping installation of $PACKAGE_NAME.${NC}"
                echo "------------------------------------------------------------"
                return 0
            fi
        fi
    else
        read -p "Do you want to install $PACKAGE_NAME? (y/n): " CHOICE
        if [[ "$CHOICE" != "y" && "$CHOICE" != "Y" ]]; then
            echo -e "${YELLOW}Skipping installation of $PACKAGE_NAME.${NC}"
            echo "------------------------------------------------------------"
            return 0
        fi
    fi

    echo -e "${BLUE}Starting installation of $PACKAGE_NAME...${NC}"

    # Install the package using pacman if available
    if command -v pacman &> /dev/null; then
        sudo pacman -Syu --noconfirm "$PACKAGE_NAME"
    else
        echo -e "${RED}Unsupported package manager for this OS. Please install ${GREEN}$PACKAGE_NAME${RED} manually.${NC}"
        echo "------------------------------------------------------------"
        return 1
    fi

    # Verify installation
    if pacman -Qi "$PACKAGE_NAME" &> /dev/null; then
        INSTALLED_VERSION=$(pacman -Qi "$PACKAGE_NAME" | grep Version | awk '{print $3}')
        echo -e "${GREEN}$PACKAGE_NAME${NC} installed successfully! Version: ${YELLOW}$INSTALLED_VERSION${NC}"
        
        # Execute initialization script
        if [[ -f "$INIT_FILE" ]]; then
            echo -e "${BLUE}Initialization script found: $INIT_FILE. Executing...${NC}"
            bash "$INIT_FILE" || {
                echo -e "${RED}Failed to execute $INIT_FILE.${NC}"
                return 1
            }
        else
            echo -e "${YELLOW}No initialization script for $PACKAGE_NAME.${NC}"
        fi

        echo "------------------------------------------------------------"
    else
        echo -e "${RED}Installation failed. Please try installing $PACKAGE_NAME manually.${NC}"
        echo "------------------------------------------------------------"
        return 1
    fi
}

# Function to check and add lines to ~/.bashrc
add_to_bashrc() {
    local line="$1"
    if ! grep -Fxq "$line" "$HOME/.bashrc"; then
        echo "$line" >> "$HOME/.bashrc"
        echo "Added to $HOME/.bashrc: $line"
    else
        echo "Already present in $HOME/.bashrc: $line"
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
