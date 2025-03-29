# Add Homebrew to PATH first
set -gx PATH /opt/homebrew/bin $PATH

# Then Herd PHP paths
fish_add_path "/Users/danielmac/Library/Application Support/Herd/bin/"
set -gx HERD_PHP_74_INI_SCAN_DIR "/Users/danielmac/Library/Application Support/Herd/config/php/74/"
set -gx HERD_PHP_81_INI_SCAN_DIR "/Users/danielmac/Library/Application Support/Herd/config/php/81/"
set -gx HERD_PHP_82_INI_SCAN_DIR "/Users/danielmac/Library/Application Support/Herd/config/php/82/"
set -gx HERD_PHP_83_INI_SCAN_DIR "/Users/danielmac/Library/Application Support/Herd/config/php/83/"

# Bun setup
set -gx BUN_INSTALL "$HOME/.bun"
fish_add_path "$BUN_INSTALL/bin"

# PNPM setup
set -gx PNPM_HOME "/Users/danielmac/Library/pnpm"
fish_add_path "$PNPM_HOME"

# Now we can use brew command
fish_add_path (brew --prefix)"/opt/python@3.12/libexec/bin"

set -gx GPG_TTY (tty)
