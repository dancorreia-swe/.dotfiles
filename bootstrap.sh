#!/bin/bash

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Detect OS
detect_os() {
    case "$(uname -s)" in
        Darwin) echo "macos" ;;
        Linux)  echo "linux" ;;
        *)      echo "unknown" ;;
    esac
}

OS=$(detect_os)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# Install package manager if needed
install_package_manager() {
    if [[ "$OS" == "macos" ]]; then
        if ! command -v brew &>/dev/null; then
            read -p "Homebrew not found. Install it? (Y/n) " -n 1 -r choice
            echo
            case "$choice" in
                n|N) error "Homebrew is required on macOS." ;;
                *)
                    info "Installing Homebrew..."
                    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
                    eval "$(/opt/homebrew/bin/brew shellenv)"
                    ;;
            esac
        fi
    elif [[ "$OS" == "linux" ]]; then
        if ! command -v pacman &>/dev/null; then
            error "This script requires Arch Linux (pacman not found)."
        fi
        # Check for yay (AUR helper)
        if ! command -v yay &>/dev/null; then
            read -p "yay (AUR helper) not found. Install it? (Y/n) " -n 1 -r choice
            echo
            case "$choice" in
                n|N) warn "Some packages from AUR won't be installable without yay." ;;
                *)
                    info "Installing yay..."
                    sudo pacman -S --needed --noconfirm git base-devel
                    git clone https://aur.archlinux.org/yay.git /tmp/yay
                    (cd /tmp/yay && makepkg -si --noconfirm)
                    rm -rf /tmp/yay
                    ;;
            esac
        fi
    fi
}

# Install stow
install_stow() {
    if command -v stow &>/dev/null; then
        return 0
    fi

    read -p "Stow not found. Install it? (Y/n) " -n 1 -r choice
    echo
    case "$choice" in
        n|N) error "Stow is required to proceed." ;;
        *)
            info "Installing stow..."
            if [[ "$OS" == "macos" ]]; then
                brew install stow
            else
                sudo pacman -S --needed --noconfirm stow
            fi
            ;;
    esac
}

# Install dependencies from Brewfile or packages.txt
install_deps() {
    read -p "Install all dependencies? (y/N) " -n 1 -r choice
    echo
    case "$choice" in
        y|Y)
            if [[ "$OS" == "macos" ]]; then
                info "Installing from Brewfile..."
                brew bundle --file="$DOTFILES_DIR/Brewfile"
            else
                info "Installing from packages.txt..."
                if command -v yay &>/dev/null; then
                    yay -S --needed --noconfirm - < "$DOTFILES_DIR/packages.txt"
                else
                    warn "yay not available, using pacman (AUR packages will be skipped)"
                    grep -v '#' "$DOTFILES_DIR/packages.txt" | grep -v 'AUR' | sudo pacman -S --needed --noconfirm -
                fi
            fi
            ;;
    esac
}

# Setup bob and neovim
setup_neovim() {
    if command -v bob &>/dev/null; then
        read -p "Install neovim nightly via bob? (y/N) " -n 1 -r choice
        echo
        case "$choice" in
            y|Y)
                info "Installing neovim nightly..."
                bob install nightly
                bob use nightly
                ;;
        esac
    fi
}

# Stow all packages
stow_packages() {
    info "Ensuring ~/.config exists..."
    if [ -L "$HOME/.config" ] && [ ! -e "$HOME/.config" ]; then
        warn "Removing broken symlink at $HOME/.config"
        rm "$HOME/.config"
    fi
    mkdir -p "$HOME/.config"

    info "Stowing packages..."
    cd "$DOTFILES_DIR"

    for package in */; do
        package=${package%/}

        # Skip non-stow directories
        [[ "$package" == ".git" ]] && continue

        # Skip macOS-specific packages on Linux
        if [[ "$OS" == "linux" ]]; then
            case "$package" in
                aerospace|aerospace-swipe|sketchybar|yabai|skhd)
                    warn "Skipping macOS-only package: $package"
                    continue
                    ;;
            esac
        fi

        if [ -d "$package" ]; then
            info "Stowing $package..."
            stow "$package"
        fi
    done
}

# Main
main() {
    info "Dotfiles bootstrap for $OS"
    echo

    install_package_manager
    install_stow
    install_deps
    setup_neovim
    stow_packages

    echo
    info "Dotfiles setup complete!"
    info "You may need to restart your shell or run: exec fish"
}

main "$@"
