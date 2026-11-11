complete -c agents-sync -f
complete -c agents-sync -n '__fish_is_nth_token 1' -a all -d 'Push ~/.dotfiles, apply here and on every box (default)'
complete -c agents-sync -n '__fish_is_nth_token 1' -a mac -d 'Apply on this Mac only'
complete -c agents-sync -n '__fish_is_nth_token 1' -a devbox -d 'Pull and apply on the devbox'
complete -c agents-sync -n '__fish_is_nth_token 1' -a vps -d 'Pull and apply on the VPS (dan and agent)'
complete -c agents-sync -n '__fish_is_nth_token 1' -a check -d 'Report drift everywhere, change nothing'
