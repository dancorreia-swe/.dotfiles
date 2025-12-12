#!/bin/bash

choice="Y"

if ! command -v brew &> /dev/null; then
    read -p "Brew not found. Do you want to install it? (Y/n) " -n 1 -r choice
    echo
fi

case "$choice" in
    y|Y )
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" 
        if [ $? -ne 0 ]; then
            echo "Homebrew installation failed. Exiting..."
            exit 1
        fi
        ;;
    n|N )
        echo "Please install Homebrew first."
        exit 1
        ;;
    * ) echo "Invalid input. Please try again." ;;
esac

if ! command -v stow &> /dev/null; then
    read -p "Stow not found. Do you want to install it? (y/N) " -n 1 -r install_stow
    echo
    if [[ $install_stow =~ ^[Yy]$ ]]; then
        echo "Installing Stow via Homebrew..."
        brew install stow
        if [ $? -ne 0 ]; then
            echo "Error: Failed to install Stow via Homebrew."
            exit 1
        fi
    else
        echo "Stow is required to proceed. Exiting."
        exit 1
    fi
fi

DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd "$DOTFILES_DIR" || exit

# Ensure ~/.config exists and is a directory
if [ -L "$HOME/.config" ] && [ ! -e "$HOME/.config" ]; then
    echo "Removing broken symlink at $HOME/.config"
    rm "$HOME/.config"
    mkdir -p "$HOME/.config"
elif [ ! -d "$HOME/.config" ]; then
    mkdir -p "$HOME/.config"
fi

echo "Stowing packages..."
for package in */ ; do
    # Remove trailing slash
    package=${package%/}
    
    # Skip directories that are not stow packages
    # .git is usually hidden from */ but explicitly checking just in case
    if [[ "$package" == ".git" ]]; then
        continue
    fi

    # Check if it's a directory (redundant with */ but safe)
    if [ -d "$package" ]; then
        echo "Stowing $package..."
        stow -v -R -t "$HOME" "$package"
    fi
done

echo "Dotfiles setup complete!"
