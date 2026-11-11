# box <box> <command> [args]: everything comes from __box_table
function __box_complete
    set -l tok (commandline -xpc)
    switch (count $tok)
        case 1
            printf '%s\t%s\n' devbox 'VM 114 at home: Orca, T3, OpenBot' vps 'Hostinger VPS: Orca, T3, OpenBot' forge 'Proxmox host'
        case 2
            for l in (__box_table)
                set -l f (string split \t -- $l)
                test "$f[1]" = "$tok[2]"; and printf '%s\t%s\n' $f[2] $f[5]
            end
        case 3
            __box_choices $tok[2] $tok[3]
    end
end
complete -c box -f -k -a '(__box_complete)'
