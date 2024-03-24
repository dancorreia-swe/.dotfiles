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
    echo "Stow not found. Installing Stow via Homebrew..."
    brew install stow
    if [ $? -ne 0 ]; then
        echo "Error: Failed to install Stow via Homebrew."
        exit 1
    fi
fi

DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd "$DOTFILES_DIR" || exit

stow -v -R -t "$HOME" .

echo "Dotfiles setup complete!"
