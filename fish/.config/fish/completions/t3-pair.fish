# t3-pair devbox|vps [label]
complete -c t3-pair -f
complete -c t3-pair -n '__fish_is_nth_token 1' -a devbox -d 'T3 Code server on the devbox'
complete -c t3-pair -n '__fish_is_nth_token 1' -a vps -d 'T3 Code server on the VPS'
