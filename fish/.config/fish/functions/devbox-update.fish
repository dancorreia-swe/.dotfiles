function devbox-update --description 'Update the devbox now: devbox-update [orca|all|apt|cli|openbot] (default: orca)'
    set -l mac (defaults read /Applications/Orca.app/Contents/Info.plist CFBundleShortVersionString 2>/dev/null; or echo "?")
    echo "Orca on this Mac: $mac"
    ssh -t devbox devbox-update $argv
end
