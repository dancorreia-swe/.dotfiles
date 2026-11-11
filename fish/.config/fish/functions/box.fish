function box --description 'One entry point for the homelab boxes: box <devbox|vps|forge> <command> [args]; box alone lists them'
    set -l table (__box_table)
    if test (count $argv) -lt 2
        if test (count $argv) -eq 1; and not string match -q -r "^$argv[1]\t" -- $table
            echo "box: unknown box '$argv[1]' (devbox, vps, forge)" >&2
            return 2
        end
        echo "box <box> <command> [args]   (Tab completes; the old names like devbox-update still work)"
        set -l last ""
        for l in $table
            set -l f (string split \t -- $l)
            test (count $argv) -eq 1; and test "$f[1]" != "$argv[1]"; and continue
            test "$f[1]" != "$last"; and echo; and set last $f[1]
            printf '  %-6s %-12s %-34s %s\n' $f[1] $f[2] $f[4] $f[5]
        end
        return 0
    end
    for l in $table
        set -l f (string split \t -- $l)
        if test "$f[1]" = "$argv[1]" -a "$f[2]" = "$argv[2]"
            set -l run (string split ' ' -- $f[3])
            $run $argv[3..]
            return $status
        end
    end
    echo "box: no '$argv[2]' for $argv[1]; 'box $argv[1]' lists its commands" >&2
    return 2
end
