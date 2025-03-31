if status is-interactive
  fish_add_path /Users/danielmac/.local/bin
  fish_add_path /opt/homebrew/bin
  fish_add_path "$HOME/.dotfiles/bin"
  fish_add_path "$HOME/.local/bin"

  oh-my-posh init fish --config $HOME/.config/ohmyposh/zen.toml | source

  zoxide init fish | source
end

