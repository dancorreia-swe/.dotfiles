function forge-gaming --description 'Bazzite gaming VM: forge-gaming [status|on|off] (web URL: $FORGE_GAMING_URL in conf.d/local.fish)'
    if not nc -z -G 1 192.168.0.100 22 >/dev/null 2>&1
        set -l web "the web UI"
        set -q FORGE_GAMING_URL; and set web $FORGE_GAMING_URL
        echo "forge (192.168.0.100) isn't reachable: this only works from home (or use $web)."
        return 1
    end
    ssh -t forge forge-gaming $argv
end
