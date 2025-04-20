if status is-interactive
  fish_add_path /Users/danielmac/.local/bin
  fish_add_path /opt/homebrew/bin
  fish_add_path "$HOME/.dotfiles/bin"
  fish_add_path "$HOME/.local/bin"

  oh-my-posh init fish --config $HOME/.config/ohmyposh/zen.toml | source

  zoxide init fish | source
end


# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init2.fish 2>/dev/null || :
