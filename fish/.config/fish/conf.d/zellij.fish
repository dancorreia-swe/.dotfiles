# ── Zellij tab naming with process icons ─────────────
# Shows icon + command while active, folder icon + dirname when idle.
# Uses Material Design nerd font icons (nf-md-*) for JetBrainsMono NF.

if not set -q ZELLIJ
    return
end

function __zellij_cmd_icon
    switch $argv[1]
        case nvim vim
            echo "󰅴"
        case node npm npx bun
            echo "󰎙"
        case python python3 pip
            echo "󰌠"
        case cargo rustc
            echo "󱘗"
        case git jj
            echo "󰊢"
        case docker
            echo "󰡨"
        case go
            echo "󰟓"
        case make cmake
            echo "󰖷"
        case ssh
            echo "󰣀"
        case '*'
            echo "󰅴"
    end
end

function __zellij_preexec --on-event fish_preexec
    set -l cmd_name (string split ' ' -- $argv[1])[1]
    set -l icon (__zellij_cmd_icon $cmd_name)
    command zellij action rename-tab "$icon $cmd_name"
end

function __zellij_postexec --on-event fish_postexec
    command zellij action rename-tab "󰉋 "(basename $PWD)
end

function __zellij_tab_name --on-variable PWD
    command zellij action rename-tab "󰉋 "(basename $PWD)
end

command zellij action rename-tab "󰉋 "(basename $PWD)
