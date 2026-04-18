# Zellij tmux Parity — Design Spec

## Goal

Make zellij feel more like tmux in three areas: session management, tab visuals (process-based icons), and keybinds — while preserving the existing locked-mode leader key workflow.

## Approach

**Approach B (Full tmux parity):** Config fixes, new keybinds, fish shell hooks for auto tab icons, session toggle script, and sessionizer cleanup.

---

## 1. Config Fixes

### Fix zjframes flickering

- Change `pane_frames true` to `pane_frames false` in `config.kdl`
- zjframes manages frame visibility itself; having `pane_frames true` causes a tug-of-war where zellij's event loop resets frames every cycle while zjframes toggles them off
- zjframes wiki explicitly documents this requirement

### Remove zellij-switch plugin dependency

- `zellij action switch-session <name>` works natively on 0.44.1+
- Replace `zellij pipe --plugin <zellij-switch.wasm>` calls with the native CLI command
- Remove the `SWITCH_PLUGIN` variable from `zellij-sessionizer`

## 2. New Keybinds

### Direct shortcut (locked mode)

| Key | Action | Notes |
|---|---|---|
| `Alt+'` | `NewTab` + `SwitchToMode "locked"` | Direct new tab without leader |

### Leader mode (`Alt+Space` → key)

| Key | Action | tmux equivalent |
|---|---|---|
| `!` | `BreakPane` + `SwitchToMode "locked"` | `prefix + !` (break pane to new tab) |
| `{` | `MovePaneBackwards` + `SwitchToMode "locked"` | `prefix + {` (swap pane backward) |
| `}` | `MovePane` + `SwitchToMode "locked"` | `prefix + }` (swap pane forward) |
| `;` | `SwitchFocus` + `SwitchToMode "locked"` | `prefix + ;` (toggle last pane) |
| `L` | Run `zellij-last-session` (floating, close_on_exit) | `prefix + L` (toggle last session) |

### Conflicts resolved

- `!` — unused in current config
- `{` / `}` — unused
- `;` — unused
- `L` — was `MoveTab "Right"` — reassign tab move to another key or accept the override

**Note on `o`:** Kept as sessionizer. Pane cycling is already covered by `p` (`SwitchFocus`) and the new `;` bind adds last-pane toggle.

**Note on `L` conflict:** Currently `L` is `MoveTab "Right"`. Since `H`/`L` in normal mode navigate tabs (`GoToPreviousTab`/`GoToNextTab`) and `Shift+H`/`Shift+L` move tabs, reassigning `L` (uppercase) to session toggle means losing tab-move-right. Options:
1. Move tab reordering to `<` / `>` (intuitive: shift+comma / shift+period)
2. Accept the override

**Decision:** Move tab reordering to `<` / `>` which is more intuitive and frees `L` for session toggle.

## 3. Session Toggle Script

### `~/.local/bin/zellij-last-session`

State files in `~/.cache/zellij/`:
- `.session-state.last` — previous session name

Logic:
1. Read last session name from state file
2. Write current `$ZELLIJ_SESSION_NAME` to state file
3. Call `zellij action switch-session <last>`

### `~/.local/bin/zellij-sessionizer` patch

Before every session switch, write the current session name to the state file:
```sh
echo -n "$ZELLIJ_SESSION_NAME" > "$HOME/.cache/zellij/.session-state.last"
```

Also replace `zellij pipe --plugin "$SWITCH_PLUGIN"` with `zellij action switch-session "$session_name"`.

## 4. Fish Tab Icon Hook

### `fish/.config/fish/conf.d/zellij_tab_icon.fish`

Two hooks:
- `fish_preexec`: Extract command name, map to icon, call `zellij action rename-tab "icon cmd"`
- `fish_postexec`: Reset tab to folder icon + directory basename

Only active when `$ZELLIJ` env var is set.

### Icon map (all Material Design range — nf-md-*)

| Process | Icon | Name | Codepoint |
|---|---|---|---|
| nvim, vim | `󰅴` | nf-md-code_tags | U+F0174 |
| node, npm, npx, bun | `󰎙` | nf-md-nodejs | U+F0399 |
| python, python3, pip | `󰌠` | nf-md-language_python | U+F0320 |
| cargo, rustc | `󱘗` | nf-md-language_rust | U+F1617 |
| git, jj | `󰊢` | nf-md-git | U+F02A2 |
| docker | `󰡨` | nf-md-docker | U+F0868 |
| go | `󰟓` | nf-md-language_go | U+F07D3 |
| make, cmake | `󰖷` | nf-md-wrench | U+F05B7 |
| ssh | `󰣀` | nf-md-ssh | U+F08C0 |
| Default (shell idle) | `󰉋` + dirname | nf-md-folder | U+F024B |

## 5. Files Changed

| File | Action |
|---|---|
| `zellij/.config/zellij/config.kdl` | Fix `pane_frames`, add `Alt+'` and tmux keybinds, reassign `H`/`L` tab moves to `<`/`>` |
| `~/.local/bin/zellij-last-session` | New script |
| `~/.local/bin/zellij-sessionizer` | Patch: state tracking + native switch |
| `fish/.config/fish/conf.d/zellij_tab_icon.fish` | New fish function |

## 6. Not Changing

- zjstatus layout config (tabs use `{name}`, icons flow through automatically)
- zjframes config options (correct as-is, only `pane_frames` was the conflict)
- Overall locked-mode / leader-key philosophy
