# Ghostty + Zellij Migration Design

## Goal

Replace WezTerm with Ghostty + Zellij to eliminate memory leak / lag issues while
preserving workspace-switching and vim-aware navigation workflows.

## Current State

- WezTerm: resurrect.wezterm + smart_workspace_switcher for session management
- Ghostty 1.x: already installed with Catppuccin Mocha, `window-save-state = always`
- Zellij 0.43.1: already installed, config exists but `session_serialization false`
- smart-splits.nvim: already configured in nvim, supports zellij natively

## Architecture

```
Ghostty (rendering, GPU accel) -> Zellij (multiplexing, sessions) -> Shell/Nvim
```

Ghostty handles display. Zellij handles splits, tabs, sessions, resurrection.
smart-splits.nvim bridges nvim <-> zellij pane navigation.

## Changes Required

### 1. Zellij Config (core work)

- `session_serialization true` + `serialize_pane_viewport true`
- `default_mode "locked"` (keys pass through to shell/nvim by default)
- Leader key pattern: Ctrl+Space prefix for zellij actions
- Catppuccin Mocha theme
- `pane_frames false` for clean look

#### Keybind Design (Leader = Ctrl+Space)

| Binding | Action |
|---------|--------|
| **Always available (locked mode)** | |
| Ctrl+hjkl | Vim-aware pane navigation (via smart-splits) |
| Arrow keys | Resize panes |
| **Leader prefix** | |
| Leader + - | Split vertical |
| Leader + \ | Split horizontal |
| Leader + m | Toggle pane zoom |
| Leader + x | Close pane |
| Leader + n | New tab |
| Leader + r | Rename tab |
| Leader + w | Session manager (switch/create/resurrect) |
| Leader + q | Detach session |

### 2. Ghostty Config (minimal)

- Add `command = zellij` to auto-launch zellij
- Ensure no conflicting keybinds with zellij

### 3. Dotfiles Structure

Create `zellij/.config/zellij/` stow package:
```
zellij/
  .config/
    zellij/
      config.kdl
      themes/
        catppuccin-mocha.kdl
```

### 4. smart-splits.nvim

No changes needed. Plugin auto-detects zellij via `$ZELLIJ` env var.

## Trade-offs

### Lost
- Per-process tab icons (nvim, fish, git with custom nerd font icons/colors)
- Custom battery/time/workspace status bar
- WezTerm's PromptInputLine for workspace naming (zellij uses its own session-manager UI)

### Gained
- No memory leaks / performance degradation over time
- Native session resurrection without plugins
- GPU-accelerated rendering (Ghostty)
- Separation of concerns (renderer vs multiplexer)
- Web client access to sessions (optional zellij feature)
