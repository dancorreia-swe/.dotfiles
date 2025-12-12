# G.dotfiles

Personal dotfiles managed with GNU Stow. Works on **macOS** and **Arch Linux (WSL)**.

## Quick Start

```bash
git clone https://github.com/danielcorreia-dev/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./bootstrap.sh
```

The bootstrap script will:
- Install Homebrew (macOS) or yay (Arch)
- Install stow and dependencies
- Setup neovim via bob
- Symlink all packages

## Usage

### Make Commands

```bash
make help           # Show all available commands
make install        # Stow all packages
make install-nvim   # Stow specific package
make uninstall-fish # Unstow specific package
make deps           # Install dependencies (Brewfile/packages.txt)
make bob            # Install bob + neovim nightly
make core           # Install core packages (fish, nvim, scripts, wezterm)
make tools          # Install tool packages (yazi, fastfetch, ohmyposh, claude)
make wm             # Install window manager packages (macOS only)
make all            # Full setup: deps + bob + all packages
make list           # List available packages
```

### Manual Stow

```bash
stow nvim           # Symlink nvim config
stow -D nvim        # Remove nvim symlinks
stow */             # Symlink all packages
```

## Packages

| Package | Description | Platform |
|---------|-------------|----------|
| `nvim` | Neovim config (lazy.nvim) | All |
| `fish` | Fish shell + functions | All |
| `wezterm` | Terminal emulator | All |
| `yazi` | File manager | All |
| `fastfetch` | System info | All |
| `ohmyposh` | Prompt theme | All |
| `claude` | Claude CLI settings | All |
| `aerospace` | Tiling window manager | macOS |
| `sketchybar` | Status bar | macOS |
| `yabai` | Window manager | macOS |
| `skhd` | Hotkey daemon | macOS |

## Dependencies

Dependencies are managed per-platform:

- **macOS**: `Brewfile` → `brew bundle`
- **Arch Linux**: `packages.txt` → `yay -S`

Neovim is installed via [bob](https://github.com/MordechaiHadad/bob) (not package managers) for easy version switching.

## Structure

```
~/.dotfiles/
├── bootstrap.sh      # Cross-platform setup script
├── Makefile          # Make targets for common operations
├── .stowrc           # Default stow options
├── Brewfile          # macOS dependencies
├── packages.txt      # Arch Linux dependencies
└── <package>/        # Each package mirrors $HOME structure
    └── .config/
        └── <app>/
```

## License

[MIT License](LICENSE)
