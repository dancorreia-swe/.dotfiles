## Which app runs this session
- The host app owns orchestration. `delegate_task` / `t3_*` tools available → T3 Code: use the `t3-workflow` skill, even if `ORCA_*` env vars are set. Otherwise `ORCA_WORKTREE_ID` set, or an Orca dispatch brief → Orca: use the `orca-workflow` skill and Orca's `orchestration` skill.
- Drive the other app only when the user names it.
- Before spawning any helper (Orca worker, T3 delegated task or thread, or a native subagent) or picking a model/effort for one, consult `~/.agents/skills/orca-workflow/references/roles.md`: size the task, add helpers only if the size calls for it, name the model.
