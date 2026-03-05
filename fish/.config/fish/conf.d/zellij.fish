# Auto-rename Zellij tabs to current directory basename
function __zellij_tab_name --on-variable PWD
    if set -q ZELLIJ
        command zellij action rename-tab (basename $PWD)
    end
end

# Rename tab 1 on session start (--on-variable PWD doesn't fire until first cd)
if set -q ZELLIJ
    command zellij action rename-tab (basename $PWD)
end
