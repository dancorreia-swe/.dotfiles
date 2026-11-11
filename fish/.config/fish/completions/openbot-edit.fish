# openbot-edit [devbox|vps] <path under /data> (the path comes from the agent)
complete -c openbot-edit -f
complete -c openbot-edit -n '__fish_is_nth_token 1' -a devbox -d 'the devbox OpenBot (default)'
complete -c openbot-edit -n '__fish_is_nth_token 1' -a vps -d 'the VPS OpenBot'
