# Ghostty + Zellij Migration Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Replace WezTerm with Ghostty + Zellij for a performant terminal with workspace switching, session resurrection, and vim-aware navigation.

**Architecture:** Ghostty renders (GPU-accelerated). Zellij multiplexes (splits, tabs, sessions). smart-splits.nvim bridges nvim <-> zellij pane navigation. Leader key (Ctrl+Space) activates a custom zellij mode for all actions.

**Tech Stack:** Ghostty, Zellij 0.43.1, smart-splits.nvim, GNU Stow, Fish shell

---

### Task 1: Create Zellij Stow Package with Config

**Files:**
- Create: `zellij/.config/zellij/config.kdl`
- Backup: `~/.config/zellij/config.kdl` -> `~/.config/zellij/config.kdl.pre-migration`

**Step 1: Back up existing zellij config**

```bash
cp ~/.config/zellij/config.kdl ~/.config/zellij/config.kdl.pre-migration
```

**Step 2: Create stow package directory**

```bash
mkdir -p ~/.dotfiles/zellij/.config/zellij
```

**Step 3: Write the new zellij config**

Create `~/.dotfiles/zellij/.config/zellij/config.kdl` with:

```kdl
// Ghostty + Zellij migration config
// Leader key: Ctrl+Space (via "leader" custom mode)

// ── Appearance ───────────────────────────────────────
theme "catppuccin-mocha"
pane_frames false
default_layout "compact"
show_startup_tips false

// ── Session Persistence ──────────────────────────────
session_serialization true
serialize_pane_viewport true
scrollback_lines_to_serialize 1000

// ── Behavior ─────────────────────────────────────────
default_mode "locked"
default_shell "fish"
mouse_mode true
copy_on_select true
scroll_buffer_size 10000
on_force_close "detach"

// ── Keybinds ─────────────────────────────────────────
// Philosophy: locked mode by default (all keys pass to shell/nvim).
// Ctrl+Space enters "leader" mode. Single key executes action, returns to locked.

keybinds clear-defaults=true {

    // --- Locked mode: keys pass through, only unlock binding active ---
    locked {
        bind "Ctrl Space" { SwitchToMode "normal"; }
    }

    // --- Normal mode acts as "leader" mode ---
    // After Ctrl+Space, press one key to act, then return to locked

    // Pane operations
    normal {
        bind "-" { NewPane "down"; SwitchToMode "locked"; }
        bind "\\" { NewPane "right"; SwitchToMode "locked"; }
        bind "m" { ToggleFocusFullscreen; SwitchToMode "locked"; }
        bind "x" { CloseFocus; SwitchToMode "locked"; }
        bind "p" { SwitchFocus; SwitchToMode "locked"; }
        bind "z" { TogglePaneFrames; SwitchToMode "locked"; }
        bind "f" { ToggleFloatingPanes; SwitchToMode "locked"; }
        bind "e" { TogglePaneEmbedOrFloating; SwitchToMode "locked"; }

        // Tab operations
        bind "n" { NewTab; SwitchToMode "locked"; }
        bind "r" { SwitchToMode "renametab"; TabNameInput 0; }
        bind "1" { GoToTab 1; SwitchToMode "locked"; }
        bind "2" { GoToTab 2; SwitchToMode "locked"; }
        bind "3" { GoToTab 3; SwitchToMode "locked"; }
        bind "4" { GoToTab 4; SwitchToMode "locked"; }
        bind "5" { GoToTab 5; SwitchToMode "locked"; }
        bind "6" { GoToTab 6; SwitchToMode "locked"; }
        bind "7" { GoToTab 7; SwitchToMode "locked"; }
        bind "8" { GoToTab 8; SwitchToMode "locked"; }
        bind "9" { GoToTab 9; SwitchToMode "locked"; }
        bind "h" { GoToPreviousTab; SwitchToMode "locked"; }
        bind "l" { GoToNextTab; SwitchToMode "locked"; }

        // Session operations
        bind "w" {
            LaunchOrFocusPlugin "session-manager" {
                floating true
                move_to_focused_tab true
            }
            SwitchToMode "locked"
        }
        bind "d" { Detach; }
        bind "q" { Quit; }

        // Sub-modes
        bind "Ctrl n" { SwitchToMode "resize"; }
        bind "Ctrl h" { SwitchToMode "move"; }
        bind "s" { SwitchToMode "scroll"; }

        // Escape back to locked
        bind "Escape" { SwitchToMode "locked"; }
        bind "Ctrl Space" { SwitchToMode "locked"; }
    }

    // --- Resize mode (Leader, Ctrl+n to enter) ---
    resize {
        bind "h" { Resize "Increase left"; }
        bind "j" { Resize "Increase down"; }
        bind "k" { Resize "Increase up"; }
        bind "l" { Resize "Increase right"; }
        bind "H" { Resize "Decrease left"; }
        bind "J" { Resize "Decrease down"; }
        bind "K" { Resize "Decrease up"; }
        bind "L" { Resize "Decrease right"; }
        bind "=" { Resize "Increase"; }
        bind "-" { Resize "Decrease"; }
        bind "Escape" { SwitchToMode "locked"; }
        bind "Enter" { SwitchToMode "locked"; }
    }

    // --- Move mode (Leader, Ctrl+h to enter) ---
    move {
        bind "h" { MovePane "left"; }
        bind "j" { MovePane "down"; }
        bind "k" { MovePane "up"; }
        bind "l" { MovePane "right"; }
        bind "n" { MovePane; }
        bind "p" { MovePaneBackwards; }
        bind "Escape" { SwitchToMode "locked"; }
        bind "Enter" { SwitchToMode "locked"; }
    }

    // --- Scroll/search mode (Leader, s to enter) ---
    scroll {
        bind "j" { ScrollDown; }
        bind "k" { ScrollUp; }
        bind "d" { HalfPageScrollDown; }
        bind "u" { HalfPageScrollUp; }
        bind "Ctrl f" { PageScrollDown; }
        bind "Ctrl b" { PageScrollUp; }
        bind "e" { EditScrollback; SwitchToMode "locked"; }
        bind "/" { SwitchToMode "entersearch"; SearchInput 0; }
        bind "Escape" { SwitchToMode "locked"; }
        bind "Ctrl Space" { SwitchToMode "locked"; }
    }

    search {
        bind "n" { Search "down"; }
        bind "p" { Search "up"; }
        bind "c" { SearchToggleOption "CaseSensitivity"; }
        bind "w" { SearchToggleOption "Wrap"; }
        bind "o" { SearchToggleOption "WholeWord"; }
        bind "Escape" { SwitchToMode "scroll"; }
    }

    entersearch {
        bind "Escape" { SwitchToMode "scroll"; }
        bind "Enter" { SwitchToMode "search"; }
    }

    renametab {
        bind "Escape" { UndoRenameTab; SwitchToMode "locked"; }
        bind "Enter" { SwitchToMode "locked"; }
    }
}

// ── Plugins ──────────────────────────────────────────
plugins {
    compact-bar location="zellij:compact-bar"
    session-manager location="zellij:session-manager"
    configuration location="zellij:configuration"
    plugin-manager location="zellij:plugin-manager"
}
```

**Step 4: Stow the zellij package**

```bash
cd ~/.dotfiles && stow zellij
```

Expected: `~/.config/zellij/config.kdl` is now a symlink to the stow package.

**Step 5: Verify zellij loads the config**

```bash
zellij --version
# Open a test session:
zellij -s test-migration
# Inside: press Ctrl+Space, then w — session manager should open
# Press Ctrl+Space, then - — should split vertically
# Press Ctrl+Space, then q — should quit
```

**Step 6: Commit**

```bash
cd ~/.dotfiles
git add zellij/.config/zellij/config.kdl
git commit -m "feat(zellij): add zellij stow package with leader-key config

Ghostty + Zellij migration step 1:
- Leader key (Ctrl+Space) for all zellij actions
- Session serialization enabled for resurrection
- Catppuccin Mocha theme
- Locked default mode for vim-aware passthrough"
```

---

### Task 2: Update Ghostty Config for Zellij Integration

**Files:**
- Modify: `ghostty/.config/ghostty/config`

**Step 1: Read current ghostty config**

File: `~/.dotfiles/ghostty/.config/ghostty/config`

**Step 2: Add zellij auto-launch and unbind conflicting keys**

Append to the Ghostty config:

```
# Zellij integration
command = zellij attach --create main
macos-option-as-alt = left

# Unbind keys that conflict with zellij
keybind = ctrl+space=unbind
```

Key decisions:
- `command = zellij attach --create main` — attaches to a session named "main" if it exists, creates it otherwise. This means closing and reopening Ghostty resumes your session.
- `macos-option-as-alt = left` — lets Alt keybinds work in zellij on macOS
- `ctrl+space=unbind` — ensures Ghostty doesn't intercept the leader key

**Step 3: Stow and verify**

```bash
cd ~/.dotfiles && stow ghostty
```

**Step 4: Test by opening Ghostty**

Open Ghostty. It should:
1. Auto-launch into zellij session "main"
2. Ctrl+Space should activate zellij leader mode
3. Ctrl+hjkl should work for navigation (passed through to shell)

**Step 5: Commit**

```bash
cd ~/.dotfiles
git add ghostty/.config/ghostty/config
git commit -m "feat(ghostty): add zellij auto-launch and unbind conflicting keys"
```

---

### Task 3: Update Dotfiles Makefile

**Files:**
- Modify: `Makefile`

**Step 1: Add ghostty and zellij to CORE packages**

In the Makefile, update the `CORE` line:

```makefile
CORE := fish nvim wezterm ghostty zellij
```

**Step 2: Commit**

```bash
cd ~/.dotfiles
git add Makefile
git commit -m "chore: add ghostty and zellij to core stow packages"
```

---

### Task 4: Verify smart-splits.nvim Auto-Detection

**Files:**
- Read: `nvim/.config/nvim/lua/gavim/plugins/editor/smart-splits-nvim.lua`

**Step 1: Confirm smart-splits detects zellij**

smart-splits.nvim auto-detects the multiplexer via environment variables. When running
inside zellij, `$ZELLIJ` is set. No config changes needed.

Verify by opening nvim inside a zellij pane:

```bash
zellij -s test-splits
# Inside zellij, open nvim:
nvim
# Create a split in nvim (:vsplit)
# Open a zellij pane: Ctrl+Space, \
# Now test Ctrl+h — should move between nvim splits AND zellij panes seamlessly
```

If it does NOT work (smart-splits doesn't detect zellij), add to the plugin config:

```lua
opts = {
  default_amount = 3,
  at_edge = 'wrap',
},
```

But this should not be needed — the plugin checks `$ZELLIJ` automatically.

**Step 2: Commit (only if changes were needed)**

```bash
cd ~/.dotfiles
git add nvim/.config/nvim/lua/gavim/plugins/editor/smart-splits-nvim.lua
git commit -m "fix(nvim): configure smart-splits for zellij detection"
```

---

### Task 5: End-to-End Smoke Test

**Step 1: Close WezTerm entirely**

**Step 2: Open Ghostty**

Verify:
- [ ] Zellij auto-starts in "main" session
- [ ] Catppuccin Mocha theme applied
- [ ] No pane frames (clean look)

**Step 3: Test leader key workflow**

- [ ] Ctrl+Space, `-` — splits vertically
- [ ] Ctrl+Space, `\` — splits horizontally
- [ ] Ctrl+Space, `m` — zooms/unzooms pane
- [ ] Ctrl+Space, `x` — closes pane
- [ ] Ctrl+Space, `n` — new tab
- [ ] Ctrl+Space, `r` — rename tab
- [ ] Ctrl+Space, `1-9` — switch to tab by number
- [ ] Ctrl+Space, `h/l` — previous/next tab

**Step 4: Test session management**

- [ ] Ctrl+Space, `w` — opens session manager
- [ ] Create a new session named "project-a"
- [ ] Switch between sessions via session manager
- [ ] Ctrl+Space, `d` — detach from session
- [ ] `zellij attach project-a` — reattach to session

**Step 5: Test vim-aware navigation**

- [ ] Open nvim in a zellij pane
- [ ] Create nvim split (:vsplit)
- [ ] Open zellij split (Ctrl+Space, \)
- [ ] Ctrl+h/j/k/l moves seamlessly between nvim and zellij panes

**Step 6: Test session resurrection**

- [ ] Create multiple tabs/panes with different cwd
- [ ] Close Ghostty completely (Cmd+Q)
- [ ] Reopen Ghostty — should reattach to "main" session with layout intact

**Step 7: Commit final state**

```bash
cd ~/.dotfiles
git add -A
git commit -m "feat: complete ghostty + zellij migration

Replaces WezTerm with Ghostty + Zellij stack:
- Ghostty: GPU-accelerated rendering, Catppuccin Mocha
- Zellij: session management, splits, resurrection
- Leader key (Ctrl+Space) mirrors WezTerm workflow
- smart-splits.nvim for vim-aware navigation"
```
