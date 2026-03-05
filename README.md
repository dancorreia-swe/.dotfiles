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

### Just Commands

```bash
just                    # List all available recipes
just install            # Stow all packages
just install-pkg nvim   # Stow specific package
just uninstall-pkg fish # Unstow specific package
just deps               # Install dependencies (Brewfile/packages.txt)
just bob                # Install bob + neovim nightly
just fisher             # Install fisher and fish plugins
just core               # Install core packages (fish, nvim, wezterm, ghostty, zellij)
just tools              # Install tool packages (yazi, fastfetch, ohmyposh, claude)
just wm                 # Install window manager packages (macOS only)
just all                # Full setup: deps + bob + stow + fisher
just list               # List available packages
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
| `ghostty` | Terminal emulator | All |
| `zellij` | Terminal multiplexer | All |
| `yazi` | File manager | All |
| `fastfetch` | System info | All |
| `ohmyposh` | Prompt theme | All |
| `claude` | Claude CLI settings | All |
| `jj` | Jujutsu VCS config | All |
| `jjui` | Jujutsu TUI config | All |
| `aerospace` | Tiling window manager | macOS |
| `aerospace-swipe` | Aerospace swipe gestures | macOS |
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
├── Justfile          # Just recipes for common operations
├── .stowrc           # Default stow options
├── Brewfile          # macOS dependencies
├── packages.txt      # Arch Linux dependencies
└── <package>/        # Each package mirrors $HOME structure
    └── .config/
        └── <app>/
```

## License

[MIT License](LICENSE)
