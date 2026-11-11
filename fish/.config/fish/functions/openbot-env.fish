function openbot-env --description 'OpenBot agent env vars: openbot-env [devbox|vps] [list|set KEY|unset KEY|apply] (devbox by default)'
    set -l h devbox
    if contains -- "$argv[1]" devbox vps
        set h $argv[1]
        set -e argv[1]
    end
    # piped input (e.g. pbpaste | openbot-env set KEY) needs ssh without -t
    if isatty stdin
        ssh -t $h openbot-env $argv
    else
        ssh $h openbot-env $argv
    end
end
