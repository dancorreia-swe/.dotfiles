# Zellij tmux Parity Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make zellij feel more like tmux — session toggle, process-based tab icons, tmux-style keybinds, and zjframes fix.

**Architecture:** Four independent changes: (1) config.kdl fixes and new keybinds, (2) session toggle script + sessionizer patch, (3) fish tab icon hook enhancement, (4) manual verification. No tests — these are config/script files validated by manual usage.

**Tech Stack:** Zellij KDL config, Bash scripts, Fish shell functions

---

### File Map

| File | Action | Responsibility |
|---|---|---|
| `zellij/.config/zellij/config.kdl` | Modify | Fix pane_frames, add keybinds |
| `~/.local/bin/zellij-last-session` | Create | Session toggle script |
| `~/.local/bin/zellij-sessionizer` | Modify | State tracking + native switch |
| `fish/.config/fish/conf.d/zellij.fish` | Modify | Add icon mapping to existing hooks |

---

### Task 1: Fix zjframes flickering and add keybinds to config.kdl

**Files:**
- Modify: `zellij/.config/zellij/config.kdl:6` (pane_frames)
- Modify: `zellij/.config/zellij/config.kdl:45-78` (locked block — add Alt+')
- Modify: `zellij/.config/zellij/config.kdl:84-178` (normal block — add tmux binds, reassign H/L)

- [ ] **Step 1: Fix pane_frames**

In `zellij/.config/zellij/config.kdl`, change line 6:

```kdl
pane_frames false
```

This fixes the zjframes flickering — zjframes manages frame visibility itself.

- [ ] **Step 2: Add Alt+' direct new tab in locked mode**

In the `locked` block (after line 77, before the closing `}`), add:

```kdl
        bind "Alt '" { NewTab; SwitchToMode "locked"; }
```

- [ ] **Step 3: Add tmux-style binds in normal mode**

In the `normal` block, add these new binds after the existing pane operations (after line 98, before the `// Tab operations` comment):

```kdl
        bind "!" { BreakPane; SwitchToMode "locked"; }
        bind "{" { MovePaneBackwards; SwitchToMode "locked"; }
        bind "}" { MovePane; SwitchToMode "locked"; }
        bind ";" { SwitchFocus; SwitchToMode "locked"; }
```

- [ ] **Step 4: Reassign tab move keys and add session toggle**

In the `normal` block, replace lines 114-115:

```kdl
        bind "H" { MoveTab "Left"; }
        bind "L" { MoveTab "Right"; }
```

with:

```kdl
        bind "<" { MoveTab "Left"; }
        bind ">" { MoveTab "Right"; }
```

Then add the session toggle bind after the existing session operations (after line 134, near `bind "d" { Detach; }`):

```kdl
        bind "L" {
            Run "/Users/danielmac/.local/bin/zellij-last-session" {
                floating true
                close_on_exit true
            }
            SwitchToMode "locked"
        }
```

- [ ] **Step 5: Commit**

```bash
jj describe -m "zellij: fix zjframes flickering and add tmux-style keybinds"
jj new
```

---

### Task 2: Create session toggle script

**Files:**
- Create: `~/.local/bin/zellij-last-session`

- [ ] **Step 1: Create the script**

Create `~/.local/bin/zellij-last-session`:

```bash
#!/usr/bin/env bash
set -euo pipefail

STATE_FILE="$HOME/.cache/zellij/.session-state.last"

mkdir -p "$(dirname "$STATE_FILE")"

current="${ZELLIJ_SESSION_NAME:-}"
if [[ -z "$current" ]]; then
  echo "Not inside a zellij session" >&2
  exit 1
fi

last="$(cat "$STATE_FILE" 2>/dev/null || true)"
if [[ -z "$last" ]]; then
  echo "No previous session recorded" >&2
  exit 1
fi

if [[ "$last" = "$current" ]]; then
  exit 0
fi

echo -n "$current" > "$STATE_FILE"
exec zellij action switch-session "$last"
```

- [ ] **Step 2: Make it executable**

```bash
chmod +x ~/.local/bin/zellij-last-session
```

- [ ] **Step 3: Commit**

```bash
jj describe -m "feat: add zellij last-session toggle script"
jj new
```

---

### Task 3: Patch sessionizer for state tracking and native switch

**Files:**
- Modify: `~/.local/bin/zellij-sessionizer:10` (remove SWITCH_PLUGIN)
- Modify: `~/.local/bin/zellij-sessionizer:103-107` (state tracking + native switch)

- [ ] **Step 1: Remove the SWITCH_PLUGIN variable**

Delete line 10 from `~/.local/bin/zellij-sessionizer`:

```bash
SWITCH_PLUGIN="${ZELLIJ_SESSIONIZER_SWITCH_PLUGIN:-"https://github.com/mostafaqanbaryan/zellij-switch/releases/download/0.2.1/zellij-switch.wasm"}"
```

- [ ] **Step 2: Replace plugin switch with native command and add state tracking**

Replace lines 103-107 in the `# ── Attach or switch` section:

```bash
if [[ -n "${ZELLIJ:-}" ]]; then
  if [[ -n "$dir" ]] && ! zellij ls -n 2>/dev/null | grep -q "^$session_name "; then
    (cd "$dir" && ZELLIJ="" zellij attach "$session_name" --create-background) 2>/dev/null
  fi
  zellij pipe --plugin "$SWITCH_PLUGIN" -- "--session $session_name"
```

with:

```bash
if [[ -n "${ZELLIJ:-}" ]]; then
  # Track current session for last-session toggle
  mkdir -p "$HOME/.cache/zellij"
  echo -n "${ZELLIJ_SESSION_NAME:-}" > "$HOME/.cache/zellij/.session-state.last"

  if [[ -n "$dir" ]] && ! zellij ls -n 2>/dev/null | grep -q "^$session_name "; then
    (cd "$dir" && ZELLIJ="" zellij attach "$session_name" --create-background) 2>/dev/null
  fi
  zellij action switch-session "$session_name"
```

The closing `else` branch (lines 108-114) stays unchanged.

- [ ] **Step 3: Commit**

```bash
jj describe -m "feat: sessionizer uses native switch-session and tracks state"
jj new
```

---

### Task 4: Add process icons to fish tab rename hook

**Files:**
- Modify: `fish/.config/fish/conf.d/zellij.fish` (replace entire file)

- [ ] **Step 1: Update zellij.fish with icon mapping**

Replace the full contents of `fish/.config/fish/conf.d/zellij.fish` with:

```fish
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
```

- [ ] **Step 2: Commit**

```bash
jj describe -m "feat: add process icons to zellij tab names via fish hooks"
jj new
```

---

### Task 5: Manual verification

- [ ] **Step 1: Restart zellij and verify zjframes**

Open a new zellij session. Confirm:
- Pane frames no longer flicker
- Frames hide for single pane, show for multiple panes / search / scroll

- [ ] **Step 2: Verify keybinds**

| Test | Keys | Expected |
|---|---|---|
| Direct new tab | `Alt+'` | New tab created from locked mode |
| Break pane to tab | `Alt+Space → !` | Focused pane becomes its own tab |
| Swap pane backward | `Alt+Space → {` | Pane swaps with previous |
| Swap pane forward | `Alt+Space → }` | Pane swaps with next |
| Toggle last pane | `Alt+Space → ;` | Focus jumps to last pane |
| Move tab left | `Alt+Space → <` | Tab moves left |
| Move tab right | `Alt+Space → >` | Tab moves right |

- [ ] **Step 3: Verify tab icons**

Run various commands and confirm icons appear:
- `nvim` → tab shows `󰅴 nvim`
- `git status` → tab shows `󰊢 git`
- Exit command → tab shows `󰉋 dirname`

- [ ] **Step 4: Verify session toggle**

1. Create two sessions: `zellij -s test1` and `zellij -s test2`
2. From test2, use sessionizer (`Alt+Space → o`) to switch to test1
3. Press `Alt+Space → L` — should switch back to test2
4. Press `Alt+Space → L` again — should switch back to test1

- [ ] **Step 5: Final commit**

```bash
jj describe -m "feat: zellij tmux parity — icons, session toggle, keybinds"
```
