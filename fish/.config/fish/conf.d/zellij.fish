# Zellij tab naming: icon + command when active, folder when idle.

if not set -q ZELLIJ
    return
end

if not status is-interactive
    return
end

function fish_title
end

function __zellij_cmd_icon
    switch $argv[1]
        case nvim vim
            echo ""
        case node npm npx
            echo "󰎙"
        case bun
            echo ""
        case python python3 pip
            echo "󰌠"
        case cargo rustc
            echo "󱘗"
        case git
            echo "󰊢"
        case jj
            echo "󰫷"
        case jjui
            echo "󰰇"
        case docker lazydocker
            echo "󰡨"
        case go
            echo "󰟓"
        case make cmake just
            echo "󰖷"
        case ssh
            echo "󰣀"
        case claude codex gemini opencode
            echo ""
        case '*'
            echo ""
    end
end

function __zellij_preexec --on-event fish_preexec
    set -l cmd_name (string split ' ' -- $argv[1])[1]
    set -l icon (__zellij_cmd_icon $cmd_name)
    set -g __zellij_active_name "$icon $cmd_name"
    command zellij action rename-tab "$__zellij_active_name"
end

function __zellij_postexec --on-event fish_postexec
    set -e __zellij_active_name
    command zellij action rename-tab "󰉋 "(basename $PWD)
end

function __zellij_tab_name --on-variable PWD
    set -q __zellij_active_name; and return
    command zellij action rename-tab "󰉋 "(basename $PWD)
end

command zellij action rename-tab "󰉋 "(basename $PWD)
