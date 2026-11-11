#!/usr/bin/env bash
# One-time setup on a host: apply agents-sync now, then install the hourly pull+sync timer.
# Usage: agents/install.sh [--no-timer]
set -euo pipefail
A=$(cd "$(dirname "$0")" && pwd -P)
command -v jq >/dev/null || { echo "agents: jq is required" >&2; exit 1; }
"$A/bin/agents-sync"
if [ "$(uname -s)" != Darwin ]; then # boxes: same command name as the Mac's fish function
  mkdir -p "$HOME/.local/bin"; ln -sfn "$A/bin/agents-sync" "$HOME/.local/bin/agents-sync"
fi
[ "${1:-}" = --no-timer ] && exit 0
case "$(uname -s)" in
  Darwin)
    p="$HOME/Library/LaunchAgents/dev.dotfiles.agents-sync.plist"
    mkdir -p "$(dirname "$p")" "$HOME/Library/Logs"
    sed "s|__HOME__|$HOME|g" "$A/launchd/dev.dotfiles.agents-sync.plist" > "$p"
    launchctl bootout "gui/$(id -u)" "$p" 2>/dev/null || true
    launchctl bootstrap "gui/$(id -u)" "$p"
    echo "agents: launchd timer installed ($p)" ;;
  *)
    d="$HOME/.config/systemd/user"; mkdir -p "$d"
    ln -sfn "$A/systemd/agents-sync.service" "$d/agents-sync.service"
    ln -sfn "$A/systemd/agents-sync.timer" "$d/agents-sync.timer"
    systemctl --user daemon-reload && systemctl --user enable --now agents-sync.timer
    [ "$(loginctl show-user "$(id -un)" -p Linger --value 2>/dev/null)" = yes ] ||
      echo "agents: linger is off, so the timer stops when you log out. Fix: sudo loginctl enable-linger $(id -un)"
    echo "agents: systemd user timer installed" ;;
esac
