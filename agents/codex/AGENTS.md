When interacting with Cloudflare, use the cf CLI unless the project has a Wrangler configuration file (then Wrangler). Apply the changes yourself; ask first only before destructive or production ones.

## Coordinating agents
- Before spawning any helper (Orca worker, T3 delegated task or thread, native subagent), picking a model or effort for one, coordinating, working a dispatched task, or handing off: load the `coordinating` skill. In Orca also load Orca's `orchestration` skill; in T3 (`delegate_task` / `t3_*` tools available, even with `ORCA_*` env vars set) it stays out.
- Drive the other app only when the user names it.
- Orca coordinator waiting: after dispatching, end the turn and idle until Orca's "You have N orchestration message(s)…" nudge; then run one `check`. Never poll: no `sleep`/`until`/`for` loops around `orca` or `gh pr checks`, and no `check` without a nudge. Emulator tap loops belong to a QA helper, never the coordinator (`coordinating`).

## Context hygiene
- Rotate, don't compact. Write the handoff and stop at the first of: ~190k tokens of context, any auto-compact warning, 25 orchestration rounds (`orca orchestration check` plus `delegate_task` calls), or a phase end (plan → build → verify, a wave boundary).
- Handoff file path and sections: `coordinating` skill §6. Then launch the successor yourself (T3: new thread; Orca: new terminal; how: the skill's host map, "New owner") with the §6 pointer, reply with its link, and stop. This standing rule is Daniel's request for that new thread; ask him only if the launch fails.
- After a usage-limit reset or "continue where you left off", re-read the handoff file before the next step.

## Worktrees and threads
- Before creating a worktree, thread or worker for a task, list existing ones (`git worktree list`, `orca worktree list`, `orca orchestration worker-list`, `t3_worktree_list`, `t3_thread_list`) and reuse the one on that ticket or branch; send it only the new instructions.
- Remove a worktree once its work is merged (`git worktree remove`, `orca worktree rm`).

## Skills
- Install into a project only the skills it will use; skip any a global plugin already provides (e.g. `mattpocock-skills`).

## Shell
- Use `git -C <path>` and absolute paths, not `cd <dir> && …`; write multi-line scripts to a file and run it, not `python3 - <<'EOF'`. Both keep commands matchable by the permission allowlist.
