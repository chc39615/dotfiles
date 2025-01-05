install_package() {
    PACKAGE_NAME=$1

    if [[ -z "$PACKAGE_NAME" ]]; then
        echo "Error: No package name provided."
        echo "Usage: install_package <package_name>"
        return 1
    fi

    echo "Checking if $PACKAGE_NAME is already installed..."

    # Check if the package is already installed
    if command -v "$PACKAGE_NAME" &> /dev/null; then
        echo "$PACKAGE_NAME is already installed."

        # Try to get the installed version
        INSTALLED_VERSION=$("$PACKAGE_NAME" --version 2>/dev/null || "$PACKAGE_NAME" -v 2>/dev/null || echo "Version information not available.")
        echo "Installed version/info: $INSTALLED_VERSION"
    else
        echo "$PACKAGE_NAME is not installed."
    fi

    # Get the repository version of the package
    echo "Checking the repository version of $PACKAGE_NAME..."
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v apt &> /dev/null; then
            REPO_VERSION=$(apt-cache policy "$PACKAGE_NAME" 2>/dev/null | grep Candidate | awk '{print $2}' || echo "Repository version not available.")
        elif command -v yum &> /dev/null; then
            REPO_VERSION=$(yum info "$PACKAGE_NAME" 2>/dev/null | grep Version | awk '{print $3}' || echo "Repository version not available.")
        elif command -v dnf &> /dev/null; then
            REPO_VERSION=$(dnf info "$PACKAGE_NAME" 2>/dev/null | grep Version | awk '{print $3}' || echo "Repository version not available.")
        elif command -v pacman &> /dev/null; then
            REPO_VERSION=$(pacman -Si "$PACKAGE_NAME" 2>/dev/null | grep Version | awk '{print $3}' || echo "Repository version not available.")
        else
            REPO_VERSION="Repository version not available."
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        if command -v brew &> /dev/null; then
            REPO_VERSION=$(brew info "$PACKAGE_NAME" | grep -m 1 "$PACKAGE_NAME:" | awk '{print $2}' || echo "Repository version not available.")
        else
            REPO_VERSION="Repository version not available."
        fi
    else
        REPO_VERSION="Repository version not available."
    fi

    echo "Repository version: $REPO_VERSION"

    # Ask the user whether to proceed with installation
    read -p "Do you want to install/reinstall $PACKAGE_NAME? (y/n): " CHOICE
    if [[ "$CHOICE" != "y" && "$CHOICE" != "Y" ]]; then
        echo "Skipping installation of $PACKAGE_NAME."
        return 0
    fi

    echo "Starting installation of $PACKAGE_NAME..."

    # Install the package using the appropriate package manager
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v apt &> /dev/null; then
            sudo apt update && sudo apt install -y "$PACKAGE_NAME"
        elif command -v yum &> /dev/null; then
            sudo yum install -y epel-release && sudo yum install -y "$PACKAGE_NAME"
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y "$PACKAGE_NAME"
        elif command -v pacman &> /dev/null; then
            sudo pacman -Syu --noconfirm "$PACKAGE_NAME"
        else
            echo "Unsupported package manager. Please install $PACKAGE_NAME manually."
            return 1
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        if command -v brew &> /dev/null; then
            brew install "$PACKAGE_NAME"
        else
            echo "Homebrew not found. Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            brew install "$PACKAGE_NAME"
        fi
    else
        echo "Unsupported operating system. Please install $PACKAGE_NAME manually."
        return 1
    fi

    # Verify installation
    if command -v "$PACKAGE_NAME" &> /dev/null; then
        echo "$PACKAGE_NAME installed successfully!"
        "$PACKAGE_NAME" --version 2>/dev/null || echo "$PACKAGE_NAME installed, but no version information available."
    else
        echo "Installation failed. Please try installing $PACKAGE_NAME manually."
        return 1
    fi
}


# Function to remove files or directories from target folder
remove_existing_files() {
    local stow_folder=$1
    local target_folder=$2

    # Loop through all files and directories in the stow folder
    for file in "$stow_folder"/*; do
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
    for file in "$stow_folder"/*; do
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
