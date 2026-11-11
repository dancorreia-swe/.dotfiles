# openbot-env [devbox|vps] [list|set KEY|unset KEY|apply]; choices come from __box_table (see box)
complete -c openbot-env -f
complete -c openbot-env -n '__fish_is_nth_token 1' -a devbox -d 'the devbox OpenBot (default)'
complete -c openbot-env -n '__fish_is_nth_token 1' -a vps -d 'the VPS OpenBot'
complete -c openbot-env -n '__fish_is_nth_token 1' -a '(__box_choices devbox openbot-env)'
complete -c openbot-env -n '__fish_is_nth_token 2; and contains -- (commandline -xpc)[2] devbox vps' -a '(__box_choices devbox openbot-env)'
