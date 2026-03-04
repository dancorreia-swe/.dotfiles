if status is-interactive
    # Cross-platform paths
    fish_add_path "$HOME/.local/share/bob/nvim-bin"
    fish_add_path "$HOME/.local/bin"

    # macOS-specific paths
    if test (uname) = Darwin
        fish_add_path /opt/homebrew/sbin
        fish_add_path /opt/homebrew/bin
    end

    oh-my-posh init fish --config $HOME/.config/ohmyposh/zen.toml | source

    zoxide init fish | source

    # ASDF configuration code
    if test -z "$ASDF_DATA_DIR"
        set _asdf_shims "$HOME/.asdf/shims"
    else
        set _asdf_shims "$ASDF_DATA_DIR/shims"
    end

    # Do not use fish_add_path (added in Fish 3.2) because it
    # potentially changes the order of items in PATH
    if not contains $_asdf_shims $PATH
        set -gx --prepend PATH $_asdf_shims
    end
    set --erase _asdf_shims

    # Machine-specific config (not tracked in git)
    if test -f ~/.config/fish/conf.d/local.fish
        source ~/.config/fish/conf.d/local.fish
    end

    # Zellij sessionizer config
    set -gx ZELLIJ_SESSIONIZER_SEARCH_PATHS "$HOME/Code"
    set -gx ZELLIJ_SESSIONIZER_SPECIFIC_PATHS "$HOME/.dotfiles"

    # Auto-start zellij in Ghostty (not nested)
    # 1. Attach to "main" on first launch
    # 2. On detach: show sessionizer picker
    # 3. On picker cancel: re-attach "main" (never bare shell)
    if test "$TERM" = xterm-ghostty; and not set -q ZELLIJ
        zellij attach --create main
        while zellij-sessionizer; end
        zellij attach --create main
    end
end

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init2.fish 2>/dev/null || :

# Mole shell completion
set -l output (mole completion fish 2>/dev/null); and echo "$output" | source
