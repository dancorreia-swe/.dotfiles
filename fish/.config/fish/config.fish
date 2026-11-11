if status is-interactive
    # Cross-platform paths
    fish_add_path "$HOME/.local/share/bob/nvim-bin"

    # macOS-specific paths
    if test (uname) = Darwin
        fish_add_path /opt/homebrew/sbin
        fish_add_path /opt/homebrew/bin
    end

    fish_add_path "$HOME/.local/bin"
    fish_add_path "$HOME/.bun/bin"

    # ASDF must follow Homebrew path setup so version-manager shims win.
    if test -z "$ASDF_DATA_DIR"
        set _asdf_shims "$HOME/.asdf/shims"
    else
        set _asdf_shims "$ASDF_DATA_DIR/shims"
    end

    # Do not use fish_add_path because it can change PATH ordering.
    # Remove an inherited shim entry first, then place it ahead of Homebrew.
    set -gx PATH $_asdf_shims (string match --invert -- $_asdf_shims $PATH)
    set --erase _asdf_shims

    oh-my-posh init fish --config $HOME/.config/ohmyposh/zen.toml | source

    zoxide init fish | source

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
    if test "$TERM" = xterm-ghostty; and not set -q ZELLIJ; and not set -q TMUX
        zellij attach --create main
        while zellij-sessionizer
        end
        zellij attach --create main
    end

    # Set vi mode
    set -gx fish_key_bindings fish_vi_key_bindings
end

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init2.fish 2>/dev/null || :

# Mole shell completion
set -l output (mole completion fish 2>/dev/null); and echo "$output" | source

# >>> grok installer >>>
fish_add_path $HOME/.grok/bin
# <<< grok installer <<<

# TeX Live (TinyTeX) - added by /setup for LaTeX CV/cover-letter compilation
fish_add_path $HOME/Library/TinyTeX/bin/universal-darwin
