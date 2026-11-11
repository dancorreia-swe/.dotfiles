function forge-ci --description 'GitHub Actions runner VM on forge: forge-ci [status|route|pause|resume]'
    if not nc -z -G 1 192.168.0.100 22 >/dev/null 2>&1
        echo "forge (192.168.0.100) isn't reachable: this only works from home (or use the PVE web Shell → forge-ci)."
        return 1
    end
    ssh -t forge forge-ci $argv
end
