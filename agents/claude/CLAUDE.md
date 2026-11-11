When interacting with Cloudflare, use the cf CLI unless the project has a Wrangler configuration file.

## Which app runs this session
- The host app owns orchestration. `delegate_task` / `t3_*` tools available → T3 Code: use `t3-workflow`, even if `ORCA_*` env vars are set (inherited from a terminal). Otherwise `ORCA_WORKTREE_ID` set, or an Orca dispatch brief → Orca: use `orca-workflow` and Orca's `orchestration` skill.
- Drive the other app only when the user names it (e.g. an Orca coordinator starting T3 threads with the `t3` CLI).
- Before spawning any helper (Orca worker, T3 delegated task or thread, or a native subagent) or picking a model/effort for one, consult `~/.agents/skills/orca-workflow/references/roles.md`: size the task, add helpers only if the size calls for it, name the model.

## Orca
- In an Orca session, load the `orca-workflow` skill before coordinating, working a dispatched task, or handing off.
- Coordinator waiting: after dispatching, end the turn and idle. Orca types "You have N orchestration message(s)…" into the terminal when something arrives; then run one `check`, process everything, and reply/release/ack in a single chained Bash call.
- Never poll: no `sleep`/`until`/`for` loops around `orca` or `gh pr checks`, and no repeated `check` calls to see whether anything arrived.

## T3 Code
- In a T3 Code thread, load the `t3-workflow` guide when choosing a model or deciding whether a task needs helpers. T3's own tools decide how to orchestrate; Orca's `orchestration` skill stays out.

## Context hygiene
- When context passes ~250k tokens or a phase ends (plan → build → verify), write a handoff brief to a file and suggest a fresh session (in Orca: hand off to a new terminal) rather than continuing.
- Screenshots: capture only the element/region needed at ≤1280px wide, never full-page retina captures; don't re-Read a screenshot already reviewed. For many visual comparisons, delegate to a subagent that returns a text verdict.
