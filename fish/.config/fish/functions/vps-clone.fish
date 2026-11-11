function vps-clone --description 'Clone a repo into ~agent/code on the vps and register it with its Orca server'
    if test (count $argv) -lt 1
        echo "usage: vps-clone <git-url> [name]" >&2
        return 1
    end
    ssh vps vps-clone (string escape -- $argv)
end
