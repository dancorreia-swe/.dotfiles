# Cross-platform dotfiles management
# Supports: macOS (Homebrew) and Arch Linux (pacman/yay)

set shell := ["bash", "-cu"]

dotfiles_dir := justfile_directory()
os := if os() == "macos" { "macos" } else { "linux" }
pkg_install := if os == "macos" { "brew install" } else { `command -v yay >/dev/null 2>&1 && echo "yay -S --needed --noconfirm" || echo "sudo pacman -S --needed --noconfirm"` }

# Package groups
core := "fish nvim wezterm ghostty zellij"
wm_mac := "aerospace aerospace-swipe sketchybar yabai skhd"
tools := "yazi fastfetch ohmyposh claude"

# List available recipes
[private]
default:
    @just --list

# List available stow packages
list:
    @echo "Available packages:"
    @find {{dotfiles_dir}} -maxdepth 1 -type d ! -name '.*' ! -name 'scripts' | xargs -n1 basename | sort | sed 's/^/  /'

# Install all stow packages
install:
    #!/usr/bin/env bash
    set -euo pipefail
    packages=$(find {{dotfiles_dir}} -maxdepth 1 -type d ! -name '.*' ! -name 'scripts' | xargs -n1 basename)
    echo "Installing all packages..."
    cd {{dotfiles_dir}} && stow $packages
    echo "Done!"

# Uninstall all stow packages
uninstall:
    #!/usr/bin/env bash
    set -euo pipefail
    packages=$(find {{dotfiles_dir}} -maxdepth 1 -type d ! -name '.*' ! -name 'scripts' | xargs -n1 basename)
    echo "Uninstalling all packages..."
    cd {{dotfiles_dir}} && stow -D $packages
    echo "Done!"

# Install specific package (e.g., just install-pkg nvim)
install-pkg pkg:
    @echo "Installing {{pkg}}..."
    @cd {{dotfiles_dir}} && stow {{pkg}}

# Uninstall specific package (e.g., just uninstall-pkg nvim)
uninstall-pkg pkg:
    @echo "Uninstalling {{pkg}}..."
    @cd {{dotfiles_dir}} && stow -D {{pkg}}

# Install system dependencies (Brewfile on mac, packages.txt on arch)
deps:
    #!/usr/bin/env bash
    set -euo pipefail
    if [[ "{{os}}" == "macos" ]]; then
        echo "Installing dependencies from Brewfile..."
        brew bundle --file={{dotfiles_dir}}/Brewfile
    else
        echo "Installing dependencies from packages.txt..."
        {{pkg_install}} $(cat {{dotfiles_dir}}/packages.txt | tr '\n' ' ')
    fi
    echo "Done!"

# Install bob (neovim version manager) and latest neovim
bob:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Installing bob-nvim..."
    if [[ "{{os}}" == "macos" ]]; then
        brew install bob
    else
        {{pkg_install}} bob
    fi
    echo "Installing neovim nightly via bob..."
    bob install nightly
    bob use nightly
    echo "Done! Neovim nightly installed via bob."

# Install fisher and fish plugins
fisher:
    @echo "Installing fisher and plugins..."
    @fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher" 2>/dev/null || true
    @fish -c "fisher update"
    @echo "Done!"

# Install core packages (fish, nvim, wezterm, ghostty, zellij)
core:
    @echo "Installing core packages..."
    @cd {{dotfiles_dir}} && stow {{core}}

# Install tool packages (yazi, fastfetch, ohmyposh, claude)
tools:
    @echo "Installing tool packages..."
    @cd {{dotfiles_dir}} && stow {{tools}}

# Install window manager packages (macOS only)
wm:
    #!/usr/bin/env bash
    set -euo pipefail
    if [[ "{{os}}" == "macos" ]]; then
        echo "Installing window manager packages..."
        cd {{dotfiles_dir}} && stow {{wm_mac}}
    else
        echo "Window manager packages are macOS only, skipping..."
    fi

# Full setup: deps + bob + stow + fisher
all: deps bob install fisher
    @echo "Full installation complete!"
