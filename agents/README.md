# agents: one shared Claude Code / Codex setup for the Mac, devbox and VPS

Git is the one-way source of truth. Edit here, commit, push; each host pulls hourly and applies it.

```
base.json            shared settings: claude (settings.json keys), codex (config.toml top-level keys),
                     hook_defs + hooks (managed hook scripts), skills, targets
hosts/<host>.json    per-host overlay, deep-merged over base (arrays replace). Host = mac on macOS,
                     otherwise `hostname -s`; override with --host or AGENTS_HOST
claude/              CLAUDE.md, hooks/*.sh, tools/* → ~/.claude/
codex/AGENTS.md      → ~/.codex/AGENTS.md
skills/<name>/       → ~/.agents/skills/<name>, plus ~/.claude/skills/<name> → that
bin/agents-sync      the sync (--dry-run shows a diff; --check exits 1 on drift)
install.sh           first run + hourly timer (launchd / systemd --user)
```

**What it owns:** only the keys it declares. Settings are deep-merged into the live file (arrays such as
`permissions.deny` are unioned), so app-managed keys (Orca/ai-memory hooks, theme, statusLine, plugins, MCP)
stay as they are. For hooks it removes and re-adds only commands under `~/.claude/hooks/<hook_defs name>.sh`.
Removing a key from the repo does **not** remove it from hosts; delete it there by hand.

**Targets:** `self` gets symlinks into this checkout. Another user (VPS `agent`, which runs T3) gets copies,
written as that user via `sudo -n -H -u <user>`, because home directories are 0700.

**Never synced:** ~/.claude.json, credentials, ai-memory config/DB, T3/Orca state, OpenBot (/data), per-project
settings.local.json, plugin caches. No secrets in this directory.

Every overwrite is backed up to `~/.claude/backups/agents-sync/<timestamp>/` first.

```sh
agents/bin/agents-sync --dry-run   # preview
agents/install.sh                  # apply now + install timer (new host)
```
