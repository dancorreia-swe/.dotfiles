if status is-interactive
    fish_add_path /Users/danielmac/.local/share/bob/nvim-bin
    fish_add_path /opt/homebrew/sbin
    fish_add_path /opt/homebrew/bin
    fish_add_path "$HOME/.dotfiles/bin"
    fish_add_path "$HOME/.local/bin"

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
end

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init2.fish 2>/dev/null || :
