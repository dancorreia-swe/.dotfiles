function vps-update --description 'Update the vps now: vps-update [orca|all|cli|openbot] (default: orca)'
    set -l mac (defaults read /Applications/Orca.app/Contents/Info.plist CFBundleShortVersionString 2>/dev/null; or echo "?")
    echo "Orca on this Mac: $mac"
    ssh -t vps vps-update $argv
end
