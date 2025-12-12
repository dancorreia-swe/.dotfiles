# Cross-platform paths

# Bun setup
set -gx BUN_INSTALL "$HOME/.bun"
fish_add_path "$BUN_INSTALL/bin"

# GPG
set -gx GPG_TTY (tty)

# fd/eza colors (if vivid is available)
if command -q vivid
    set -gx LS_COLORS (vivid generate catppuccin-mocha)
end

# macOS-specific paths
if test (uname) = "Darwin"
    # Homebrew
    set -gx PATH /opt/homebrew/bin $PATH

    # Herd PHP (if installed)
    if test -d "$HOME/Library/Application Support/Herd"
        fish_add_path "$HOME/Library/Application Support/Herd/bin/"
        set -gx HERD_PHP_74_INI_SCAN_DIR "$HOME/Library/Application Support/Herd/config/php/74/"
        set -gx HERD_PHP_81_INI_SCAN_DIR "$HOME/Library/Application Support/Herd/config/php/81/"
        set -gx HERD_PHP_82_INI_SCAN_DIR "$HOME/Library/Application Support/Herd/config/php/82/"
        set -gx HERD_PHP_83_INI_SCAN_DIR "$HOME/Library/Application Support/Herd/config/php/83/"
    end

    # PNPM (macOS location)
    set -gx PNPM_HOME "$HOME/Library/pnpm"
    fish_add_path "$PNPM_HOME"

    # Python via Homebrew
    if command -q brew
        fish_add_path (brew --prefix)"/opt/python@3.12/libexec/bin"
    end
else
    # Linux PNPM location
    set -gx PNPM_HOME "$HOME/.local/share/pnpm"
    fish_add_path "$PNPM_HOME"
end
