function forge-update --description 'Update forge containers now: forge-update [all|cts|check|host|<ctid>...] (default: all)'
    if not nc -z -G 1 192.168.0.100 22 >/dev/null 2>&1
        echo "forge (192.168.0.100) isn't reachable: this only works from home (or use the PVE web Shell → forge-update)."
        return 1
    end
    ssh -t forge forge-update $argv
end
