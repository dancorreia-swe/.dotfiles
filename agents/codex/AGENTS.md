When interacting with Cloudflare, use the cf CLI unless the project has a Wrangler configuration file (then Wrangler). Apply the changes yourself; ask first only before destructive or production ones.

## Which app runs this session
- The host app owns orchestration. `delegate_task` / `t3_*` tools available → T3 Code: use the `t3-workflow` skill, even if `ORCA_*` env vars are set. Otherwise `ORCA_WORKTREE_ID` set, or an Orca dispatch brief → Orca: use the `orca-workflow` skill and Orca's `orchestration` skill.
- Drive the other app only when the user names it.
- Before spawning any helper (Orca worker, T3 delegated task or thread, or a native subagent) or picking a model/effort for one, consult `~/.agents/skills/orca-workflow/references/roles.md`: size the task, add helpers only if the size calls for it, name the model.
- Orca coordinator waiting: after dispatching, end the turn and idle until Orca's "You have N orchestration message(s)…" nudge; then run one `check`. Never poll: no `sleep`/`until`/`for` loops around `orca` or `gh pr checks`, and no `check` without a nudge. Emulator tap loops belong to a QA helper, never the coordinator (`orca-workflow`).

## Context hygiene
- Rotate, don't compact. Write the handoff and stop at the first of: ~190k tokens of context, any auto-compact warning, 25 orchestration rounds (Orca nudges processed, or T3 child results received), or a phase end (plan → build → verify, a wave boundary).
- Handoff: `~/.<project>-coordinator/HANDOFF.md` for a coordinator, `~/.<project>-handoffs/<topic>.md` otherwise. Sections as in `orca-workflow` §3: brief verbatim, standing decisions, state, open items, START HERE. Then tell Daniel to start a fresh session (Orca: new terminal; T3: new thread) from "Read <file> in full, start at START HERE".
- After a usage-limit reset or "continue where you left off", re-read the handoff file before the next step.

## Worktrees and threads
- Before creating a worktree, thread or worker for a task, list existing ones (`git worktree list`, `orca worktree list`, `orca orchestration worker-list`, `t3_worktree_list`, `t3_thread_list`) and reuse the one on that ticket or branch; send it only the new instructions.
- Remove a worktree once its work is merged (`git worktree remove`, `orca worktree rm`).

## Skills
- Install into a project only the skills it will use; skip any a global plugin already provides (e.g. `mattpocock-skills`).

## Shell
- Use `git -C <path>` and absolute paths, not `cd <dir> && …`; write multi-line scripts to a file and run it, not `python3 - <<'EOF'`. Both keep commands matchable by the permission allowlist.
