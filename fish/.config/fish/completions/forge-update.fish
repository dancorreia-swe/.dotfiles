# choices come from __box_table (see box)
complete -c forge-update -f -n '__fish_is_nth_token 1' -a '(__box_choices forge update)'
