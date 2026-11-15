# agents: one shared Claude Code / Codex setup for the Mac, devbox and VPS

Git is the one-way source of truth. Edit here, commit, push; each host pulls hourly and applies it.

```
base.json            shared settings: claude (settings.json keys), codex (config.toml top-level keys),
                     hook_defs + hooks (managed hook scripts), skill_repos, targets
hosts/<host>.json    per-host overlay, deep-merged over base (arrays replace). Host = mac on macOS,
                     otherwise `hostname -s`; override with --host or AGENTS_HOST
claude/              CLAUDE.md, hooks/*.sh, tools/* → ~/.claude/ (hooks/*.sh also → ~/.codex/hooks/)
codex/AGENTS.md      → ~/.codex/AGENTS.md
bin/agents-sync      the sync (--dry-run shows a diff; --check exits 1 on drift)
install.sh           first run + hourly timer (launchd / systemd --user)
```

**What it owns:** only the keys it declares. Settings are deep-merged into the live file (arrays such as
`permissions.deny` are unioned), so app-managed keys (Orca/ai-memory hooks, theme, statusLine, plugins, MCP)
stay as they are. For hooks it removes and re-adds only commands under `~/.claude/hooks/<hook_defs name>.sh`
(in settings.json) and `~/.codex/hooks/<name>.sh` (in `~/.codex/hooks.json`; Codex hooks share Claude's input format). Codex runs a
new or changed hook only after one review per host: `/hooks` in Codex. It keys trust by position, so ours stay last.
Removing a key from the repo does **not** remove it from hosts; delete it there by hand.

**Skills** are published, not copied: each repo in `skill_repos` (e.g. the private `dancorreia-swe/skills`)
is installed once with `npx skills add <repo> -g` (→ `~/.agents/skills`, linked into `~/.claude/skills`), then
every run does `npx skills update -g` for that repo's skills. Edit skills in that repo, push, and every host
picks them up within the hour (or now: `agents-sync all`). Project skills stay in each project's `skills-lock.json`.

**Targets:** `self` gets symlinks into this checkout. Another user (VPS `agent`, which runs T3) gets copies,
written as that user via `sudo -n -H -u <user>`, because home directories are 0700.

**Never synced:** ~/.claude.json, credentials, ai-memory config/DB, T3/Orca state, OpenBot (/data), per-project
settings.local.json, plugin caches. No secrets in this directory.

Every overwrite is backed up to `~/.claude/backups/agents-sync/<timestamp>/` first.

```sh
agents/bin/agents-sync --dry-run   # preview
agents/install.sh                  # apply now + install timer (new host)
```
