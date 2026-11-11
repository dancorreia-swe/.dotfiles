function agents-sync --description 'Shared Claude/Codex setup: agents-sync [all|mac|devbox|vps|check] (default all: push ~/.dotfiles, apply here and on every box)'
    set -l repo ~/.dotfiles
    set -l bin $repo/agents/bin/agents-sync
    set -l what all
    test (count $argv) -gt 0; and set what $argv[1]
    if not contains -- $what all mac devbox vps check
        echo "usage: agents-sync [all|mac|devbox|vps|check]" >&2
        return 2
    end

    # all: the boxes pull from GitHub, so publish first
    if test $what = all
        set -l dirty (git -C $repo status --porcelain -- agents)
        if test (count $dirty) -gt 0
            echo "agents-sync: ~/.dotfiles/agents has uncommitted changes; commit them first (the boxes pull from GitHub)" >&2
            return 1
        end
        git -C $repo fetch -q origin; or return
        set -l ahead (git -C $repo rev-list --count origin/main..HEAD)
        if test $ahead -gt 0
            if not git -C $repo merge-base --is-ancestor origin/main HEAD
                echo "agents-sync: ~/.dotfiles has diverged from origin/main; rebase first" >&2
                return 1
            end
            git -C $repo push -q origin HEAD:main; or return
            # jj checkout: keep its main bookmark on what was pushed
            if test -d $repo/.jj; and command -q jj
                jj -R $repo bookmark set main -r (git -C $repo rev-parse HEAD) >/dev/null 2>&1
            end
            echo "pushed $ahead commit(s) to origin/main"
        end
    end

    set -l rc 0
    if contains -- $what all mac check
        echo "## mac"
        if test $what = check
            $bin --check; or set rc 1
        else
            $bin; or set rc 1
        end
    end
    set -l boxes devbox vps
    contains -- $what devbox vps; and set boxes $what
    test $what = mac; and set boxes
    set -l flags --pull
    test $what = check; and set flags --pull --check
    for h in $boxes
        echo "## $h"
        ssh -o ConnectTimeout=5 -o ForwardAgent=no $h "~/.local/bin/agents-sync $flags"
        switch $status
            case 0
            case 255
                echo "  $h unreachable (Tailscale off?); its hourly timer will catch up"
                set rc 1
            case '*'
                set rc 1
        end
    end
    return $rc
end
