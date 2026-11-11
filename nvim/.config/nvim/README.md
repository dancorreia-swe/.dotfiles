# GaVim

Personal Neovim config (nightly, `lazy.nvim`). It started from kickstart.nvim and
borrows a small util layer from LazyVim (`_G.GaVim`, `lua/gavim/util`).

Code is mostly written by agents (Claude Code, Codex, …). Neovim is for **reading
and navigating** code, reviewing what the agents changed, and editing prompts or
commit messages. The config is tuned for that:

- Files changed on disk show up right away (see [Live reload](#live-reload)).
- Formatters only run when the project is configured for them, so an agent's
  output is never restyled behind its back.
- No inline AI completion. Agents run in their own terminal and talk to Neovim
  over the Claude Code IDE protocol, or through sidekick.

## Layout

```
init.lua                    leader, options/keymaps/autocmds, lazy bootstrap
lua/gavim/config/           options, keymaps, autocmds (incl. live reload + quick-edit)
lua/gavim/util/             GaVim helpers (root, lsp, format, treesitter, watch, ...)
lua/gavim/plugins/<group>/  one spec per plugin: ai, coding, editor, lang, lsp, ui
after/                      ftplugins / queries
```

## Agent integration

### Claude Code: `coder/claudecode.nvim`

Neovim exposes the same IDE protocol as the VS Code and JetBrains extensions. It
starts a WebSocket server and writes `~/.claude/ide/<port>.lock`.

- **Claude in another terminal** (Orca, zellij, …) in the same project: run
  `/ide` and pick Neovim. Claude can then see the current file and selection,
  read LSP diagnostics, and open its proposed edits here as diffs.
- **Claude inside Neovim**: `<leader>ac` opens a Snacks terminal on the right.

| Key          | Action                                                      |
| ------------ | ----------------------------------------------------------- |
| `<leader>ac` | Toggle Claude (visual: send selection)                      |
| `<leader>aC` | Claude `--continue`                                         |
| `<leader>ab` | Add buffer (or the file under the cursor in explorer/yazi)  |
| `<leader>ay` | Accept the proposed diff                                    |
| `<leader>an` | Deny the proposed diff                                      |
| `<leader>aS` | Server status                                               |

Diffs open in a new tab. `:w` in the diff also accepts it.

### Any agent CLI: `folke/sidekick.nvim`

Runs Codex, Claude, opencode, gemini, etc. in a split, or in a zellij session if
zellij is installed, and sends them context. Copilot NES is disabled.

| Key          | Action                                    |
| ------------ | ----------------------------------------- |
| `<c-.>`      | Toggle the CLI (works from terminal mode) |
| `<leader>aa` | Toggle the CLI                            |
| `<leader>as` | Pick an installed CLI                     |
| `<leader>at` | Send `{this}` (position or selection)     |
| `<leader>af` | Send the file                             |
| `<leader>av` | Send the visual selection                 |
| `<leader>ax` | Send the diagnostics                      |
| `<leader>ap` | Prompt picker                             |
| `<leader>ad` | Detach the session                        |

### Neovim as `$EDITOR` (quick-edit mode)

Claude Code's `Ctrl-G` (edit prompt), Codex, `git commit` and `jj describe`
launch `$EDITOR` on a temp file. Quick-edit mode is on when Neovim is started
with a single file that is:

- under `$TMPDIR`, `/tmp` or `/var/folders`, or
- named `COMMIT_EDITMSG`, `MERGE_MSG`, `TAG_EDITMSG` or `*.jjdescription`.

In that mode:

- the Claude Code server and session persistence don't start;
- autoformat is off;
- `wrap`, `linebreak` and `spell` are on;
- `<C-s>` writes and quits, handing the text back to the tool.

```fish
set -Ux EDITOR nvim   # or: claude config / codex settings
```

### Live reload

Agents edit files while Neovim has them open:

- Directories of loaded buffers are watched with libuv `fs_event`. A change
  triggers a debounced `:checktime`, so no focus change or keypress is needed.
  `checktime` also runs on focus, `BufEnter` and `CursorHold`.
- An **unmodified** buffer reloads silently.
- A **modified** buffer is never overwritten. You get one warning, then choose
  `:e!` to take the disk version or `:w!` to keep yours.
- Autosave on `FocusLost`/`BufLeave` skips buffers in that conflict state, so
  it can't overwrite an agent's edit.

## Formatting and linting

`conform.nvim` formats on save. Formatters are gated on project config:

| Filetype            | Formatter                                                                                    |
| ------------------- | -------------------------------------------------------------------------------------------- |
| js/ts/json/css      | `biome` if `biome.json(c)` exists, else `prettierd`/`prettier` if a prettier config exists, else LSP |
| html                | prettier (with a config)                                                                     |
| markdown            | prettier (with a config); `markdownlint-cli2` only with lint errors; `markdown-toc` only with `<!-- toc -->` |
| lua / php / toml    | `stylua` / `pint` or `php-cs-fixer` / `taplo`                                                |

- `markdownlint-cli2` lints only where the project has a `.markdownlint*` or
  `.markdownlint-cli2*` config, so notes, plans and `CLAUDE.md` stay quiet.
- `eslint_d` lints only when an eslint config exists, including flat
  `eslint.config.*`.
- Toggle autoformat with `<leader>uf` (global) or `<leader>uF` (buffer).
  `<leader>F` or `:Format` formats manually.

## Markdown

- `render-markdown.nvim` (obsidian preset) renders in the buffer. Toggle with
  `<leader>um`.
- `marksman` handles links, headings and references across files.
- `markdown-preview.nvim` previews in the browser with `<leader>cp`.
- `obsidian.nvim` covers the vaults. Its own UI is off so it doesn't fight
  render-markdown. Keys are under `<leader>o`, and `o` on the dashboard opens
  quick switch.

## Other keymaps worth knowing

| Key                       | Action                                          |
| ------------------------- | ----------------------------------------------- |
| `<leader>gg`              | Lazygit (was `<leader>lg`)                      |
| `<leader>xd`              | Diagnostics to loclist (was `<leader>q`)        |
| `<leader>qq`              | Quit all; `<leader>q*` also has session keys    |
| `<leader>h*`              | haunt.nvim annotations                          |
| `<leader>e` / `nvim .`    | Snacks explorer (yazi on its own keys)          |
| `<leader>sU`              | Built-in undotree                               |
| `<leader>snt`             | Noice history picker                            |

`<leader>` with which-key shows the rest.

## Removed plugins and why

| Plugin                                     | Reason                                                   |
| ------------------------------------------ | -------------------------------------------------------- |
| copilot.lua (+ lualine and toggle)         | No inline AI typing; agents run in their own CLI          |
| fzf-lua                                    | Duplicated the Snacks picker                              |
| nvim-dap and adapters, neotest             | Agents run tests and debug; not used for reading code     |
| oil.nvim                                   | Snacks explorer and yazi already cover it                 |
| yanky, dial, nvim-autopairs, mini.surround | Typing aids for a config that rarely types code           |
| mini.comment + ts-context-commentstring    | Replaced by native `gc` + `folke/ts-comments.nvim`        |
| emmet-language-server, nvim-navic          | Emmet: typing aid. Navic: never attached (dropbar covers it) |

## Requirements

- Neovim nightly (`bob use nightly`), `git`, `rg`, `fd`, a Nerd Font.
- `tree-sitter` CLI for parser builds. Installed automatically through mason if
  missing.
- Optional: `lazygit`, `yazi`, `zellij`, and `imagemagick` + `mmdc` (mermaid)
  for Snacks image rendering.
- Mason installs LSPs and formatters. `:checkhealth` should be clean apart from
  optional toolchains.
