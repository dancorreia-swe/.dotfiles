function devbox-clone --description 'Clone a repo into ~/code on the devbox and register it with its Orca server'
    if test (count $argv) -lt 1
        echo "usage: devbox-clone <git-url> [name]" >&2
        return 1
    end
    ssh devbox orca-clone (string escape -- $argv)
end
