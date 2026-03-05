# ── Zellij tab naming ────────────────────────────────
# Shows running command while active, directory name when idle.
# Manual renames (Leader+r) get overwritten on next command — that's intentional.

if not set -q ZELLIJ
    return
end

# Show command name when a command starts
function __zellij_preexec --on-event fish_preexec
    set -l cmd_name (string split ' ' -- $argv[1])[1]
    command zellij action rename-tab "$cmd_name"
end

# Show directory name when command finishes (idle at prompt)
function __zellij_postexec --on-event fish_postexec
    command zellij action rename-tab (basename $PWD)
end

# Rename on cd (covers cd without running a visible command)
function __zellij_tab_name --on-variable PWD
    command zellij action rename-tab (basename $PWD)
end

# Initial rename on session start
command zellij action rename-tab (basename $PWD)
