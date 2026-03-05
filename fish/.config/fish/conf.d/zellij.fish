# Auto-rename Zellij tabs to current directory basename
function __zellij_tab_name --on-variable PWD
    if set -q ZELLIJ
        command zellij action rename-tab (basename $PWD)
    end
end
