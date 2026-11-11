function t3-pair --description 'One-time T3 Code pairing link + QR for the devbox or vps (copies the link)'
    if not contains -- "$argv[1]" devbox vps
        echo "usage: t3-pair devbox|vps [label]" >&2
        return 2
    end
    set -l out (ssh $argv[1] t3-pair $argv[2..]); or return
    printf '%s\n' $out
    string match -r '^http\S+' -- $out | pbcopy; and echo "(link copied to the clipboard)"
end
