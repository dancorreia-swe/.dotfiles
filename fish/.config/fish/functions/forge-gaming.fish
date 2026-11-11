function forge-gaming --description 'Bazzite gaming VM: forge-gaming [status|on|off] (web: https://gaming.home.dancorreia.dev)'
    if not nc -z -G 1 192.168.0.100 22 >/dev/null 2>&1
        echo "forge (192.168.0.100) isn't reachable: this only works from home (or use https://gaming.home.dancorreia.dev)."
        return 1
    end
    ssh -t forge forge-gaming $argv
end
