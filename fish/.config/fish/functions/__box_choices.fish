function __box_choices --description 'Tab choices for one box command: __box_choices <host> <command>'
    for l in (__box_table)
        set -l f (string split \t -- $l)
        if test "$f[1]" = "$argv[1]" -a "$f[2]" = "$argv[2]" -a -n "$f[6]"
            for c in (string split ';' -- $f[6])
                string replace '=' \t -- $c
            end
        end
    end
end
