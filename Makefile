# Cross-platform dotfiles management
# Supports: macOS (Homebrew) and Arch Linux (pacman/yay)

SHELL := /bin/bash
DOTFILES_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
PACKAGES := $(shell find $(DOTFILES_DIR) -maxdepth 1 -type d ! -name '.*' ! -name 'scripts' -printf '%f\n' 2>/dev/null || find $(DOTFILES_DIR) -maxdepth 1 -type d ! -name '.*' ! -name 'scripts' | xargs -n1 basename)

# Detect OS
UNAME := $(shell uname -s)
ifeq ($(UNAME),Darwin)
    OS := macos
    PKG_INSTALL := brew install
    PKG_BUNDLE := brew bundle --file=$(DOTFILES_DIR)/Brewfile
else
    OS := linux
    # Prefer yay for AUR support, fallback to pacman
    PKG_INSTALL := $(shell command -v yay >/dev/null 2>&1 && echo "yay -S --needed --noconfirm" || echo "sudo pacman -S --needed --noconfirm")
    PKG_BUNDLE := $(PKG_INSTALL) - < $(DOTFILES_DIR)/packages.txt
endif

# Package groups
CORE := fish nvim scripts wezterm
WM_MAC := aerospace aerospace-swipe sketchybar yabai skhd
TOOLS := yazi fastfetch ohmyposh claude

.PHONY: help install uninstall list deps bob fisher core tools wm all

help: ## Show this help
	@echo "Dotfiles Management ($(OS))"
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "Package targets:"
	@echo "  make install-PKG    Install specific package (e.g., make install-nvim)"
	@echo "  make uninstall-PKG  Uninstall specific package (e.g., make uninstall-nvim)"

install: ## Install all stow packages
	@echo "Installing all packages..."
	@cd $(DOTFILES_DIR) && stow $(PACKAGES)
	@echo "Done!"

uninstall: ## Uninstall all stow packages
	@echo "Uninstalling all packages..."
	@cd $(DOTFILES_DIR) && stow -D $(PACKAGES)
	@echo "Done!"

install-%: ## Install specific package (e.g., make install-nvim)
	@echo "Installing $*..."
	@cd $(DOTFILES_DIR) && stow $*

uninstall-%: ## Uninstall specific package (e.g., make uninstall-nvim)
	@echo "Uninstalling $*..."
	@cd $(DOTFILES_DIR) && stow -D $*

list: ## List available packages
	@echo "Available packages:"
	@echo $(PACKAGES) | tr ' ' '\n' | sort | sed 's/^/  /'

deps: ## Install system dependencies (Brewfile on mac, packages.txt on arch)
ifeq ($(OS),macos)
	@echo "Installing dependencies from Brewfile..."
	@$(PKG_BUNDLE)
else
	@echo "Installing dependencies from packages.txt..."
	@$(PKG_BUNDLE)
endif
	@echo "Done!"

bob: ## Install bob (neovim version manager) and latest neovim
	@echo "Installing bob-nvim..."
ifeq ($(OS),macos)
	@brew install bob
else
	@$(PKG_INSTALL) bob
endif
	@echo "Installing neovim nightly via bob..."
	@bob install nightly
	@bob use nightly
	@echo "Done! Neovim nightly installed via bob."

fisher: ## Install fisher and fish plugins
	@echo "Installing fisher and plugins..."
	@fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher" 2>/dev/null || true
	@fish -c "fisher update"
	@echo "Done!"

core: ## Install core packages (fish, nvim, scripts, wezterm)
	@echo "Installing core packages..."
	@cd $(DOTFILES_DIR) && stow $(CORE)

tools: ## Install tool packages (yazi, fastfetch, ohmyposh, claude)
	@echo "Installing tool packages..."
	@cd $(DOTFILES_DIR) && stow $(TOOLS)

wm: ## Install window manager packages (macOS only)
ifeq ($(OS),macos)
	@echo "Installing window manager packages..."
	@cd $(DOTFILES_DIR) && stow $(WM_MAC)
else
	@echo "Window manager packages are macOS only, skipping..."
endif

all: deps bob install fisher ## Full setup: deps + bob + stow + fisher
	@echo "Full installation complete!"
