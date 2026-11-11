function openbot-edit --description 'Edit a file in an OpenBot container: openbot-edit [devbox|vps] /data/OpenBot/Agents/.../file (devbox by default)'
    set -l h devbox
    if contains -- "$argv[1]" devbox vps
        set h $argv[1]
        set -e argv[1]
    end
    ssh -t $h openbot-edit (string escape -- $argv)
end
