---
name: orca-workflow
description: Daniel's Orca working conventions for coordinators, dispatched workers, handoffs, QA sweeps and decision gates — token-efficient waiting, worker specs, handoff files, PR landing, plus a guide to picking model, effort and helper roles (planner, strategist, designer, QA, advisor, reviewer) by task difficulty. Load in any Orca session (ORCA_WORKTREE_ID set) before coordinating, working a dispatched task, or handing off.
---

# Orca workflow (Daniel's conventions)

Complements Orca's own guides. Get exact command syntax from `orca skills get orchestration`
(coordination) and the `orca-cli` skill (worktrees, terminals, handoffs). This file covers how
Daniel runs the work and how to keep it cheap.

**Host check:** this skill applies when Orca runs the session (`ORCA_WORKTREE_ID` set). If
`delegate_task` / `t3_*` tools are available, T3 Code is the host: use `t3-workflow` instead.

**Picking model, effort and helpers:** [references/roles.md](references/roles.md) is a guide
to consult when starting a worker or bringing in a helper. Orca's own orchestration decides
how work flows; the guide only helps choose what each piece runs on.

## Pick your part

| Situation | Part | Section |
|---|---|---|
| Brief says "you are the coordinator", "run waves", "orchestrate" | Coordinator | 1 |
| Brief starts "You are working inside Orca… dispatched worker" | Worker | 2 |
| "Take over", "pick up", "read the handoff at …" | Handoff owner | 3 |
| QA verify or QA fix on staging | QA sweep | 4 |
| `ready-for-human` ticket, or a choice only Daniel can make | Decision gate | 5 |

## Token rules (all parts)

- **Waiting costs a full-context turn.** After dispatching, end the turn and idle; Orca's
  nudge wakes you. Watch CI with `gh pr checks <n> --watch` in a background Bash call.
- **Name the model on every launch.** A worker launched without `--model` inherits a default
  that is often the heavy tier; roles.md suggests one by difficulty.
- Chain commands that belong together into ONE Bash call, e.g. reply + release + ack.
- Keep large output out of context: pipe through `jq`/`head`, write logs to files, read only
  the lines you need.
- Screenshots: only the element or region needed, at ≤1280px wide, read once.
- **QA loops run in a fresh context.** Emulator, simulator or browser checking (tap →
  look → tap) goes to a QA subagent (Sonnet; Haiku for re-checks) that returns pass/fail
  per criterion with evidence paths. Read `orca emulator ax --json` before reaching for a
  screenshot; keep screenshots for genuinely visual checks. A hook nudges the main agent at
  8 device calls and stops it at 20.
- When context passes ~250k or a phase ends, update the handoff file (section 3) and suggest
  a fresh session.

## 1. Coordinator

**Setup**
1. Read AGENTS.md, CONTEXT.md (glossary), docs/adr/ and docs/agents/. Leave source code to
   workers.
2. Create one Run for the objective and note its id in the handoff file right away.
3. Work out the **frontier**: open tickets with no open blockers and the `ready-for-agent`
   label. GitHub: `gh api repos/<owner>/<repo>/issues/<n>/dependencies/blocked_by`. Linear:
   `orca linear`.
4. Give each frontier ticket a quick size (roles.md); it suggests the worker's model and
   whether a planner, designer, advisor or reviewer is worth adding.
   The coordinator itself stays on Opus.
5. Raise blockers that need Daniel (`ready-for-human`, hosting/vendor/legal choices) at once
   as a section 5 decision brief, and keep them out of the wave.

**Waves**
- At most 5 workers at a time. Each gets its own new worktree branched from `main`. Follow
  the brief's priority list (go-live critical path first).
- `worker-start` takes `--agent`, `--model` and `--effort`; pick them from roles.md (e.g.
  `--agent codex` for a second-family review, `claude-fable-5-2` for an extra-hard advisor).
- Worker spec = Orca's task-spec contract:
  - **Target:** the issue number(s). Tell the worker to read the issue, the issues it cites
    as "Decided in", CONTEXT.md and the relevant ADRs.
  - **Change:** the ticket's "What to build" plus every acceptance criterion.
  - **Constraints:** glossary vocabulary, the ADRs, project language rules from AGENTS.md,
    and staying inside the ticket's scope.
  - **Ownership:** its own worktree and branch only. One PR against `main` with
    `Closes #<n>` and the acceptance criteria ticked.
  - **Observable acceptance:** tests plus the project's check commands pass, and the PR link
    goes in `worker_done`.
- Paste the triage "Agent brief" if there is one, not whole issue threads. The worker can
  `gh issue view` the rest.
- Group closely related QA issues into one worker (e.g. `#186 #212`) when they touch the
  same code.

**Processing messages**
- On the nudge (`You have N orchestration message(s)…`): run ONE
  `orca orchestration check --run <id> --json` and process every message. Answer from the
  ticket, PRD, CONTEXT.md and ADRs; escalate to Daniel only what contradicts an ADR or needs
  his call. Finish with one chained Bash call: replies + `worker-release`/reuse +
  `check --ack <delivery_id>`.
- A worker reporting the task is bigger or harder than briefed often needs a model step up
  or a helper from roles.md rather than another attempt on the same tier.
- A background `check --wait --timeout-ms 900000` is only for headless or automation runs
  where no nudges arrive.
- Reviews come from a reviewer worker's verdict; the coordinator keeps diffs and logs out of
  its own context.
- Reviewers read the diff (`code-review`), not the running app; checking the app is a
  separate QA pass on a light model. A re-review gets only the commits since the last review
  plus the earlier findings.

**Merging and reporting**
- **Merge only with Daniel's go-ahead.** At a wave boundary, list each ready PR with a
  one-line summary, and ask once whether to merge them.
- Wave-boundary report: done (tickets and PRs) · in flight · blocked, and on what · next
  wave. Bring up Daniel's open items only at wave boundaries.
- Release or reuse every settled worker. Once PRs merge, remove closed worktrees
  (`orca worktree rm`).
- **Fresh coordinator per wave.** Once the wave-boundary notes are in the handoff file, the
  next wave starts best with a new coordinator spawned from it (section 3), so each wave
  begins at a small context instead of carrying every earlier one.

## 2. Dispatched worker

1. Do only the task. Read the issue and its "Decided in" issues, CONTEXT.md, the relevant
   ADRs and AGENTS.md.
2. Bring in helpers only when the task calls for it (roles.md), naming their model. Helpers
   are your own subagents; an Orca worker is for when the helper needs its own worktree or
   a different agent family (e.g. a Codex review).
3. Build it, add tests to the existing harness, run the project's check and type-check
   commands. Hand UI verification (browser via `playwright-cli`, or emulator) to a QA
   subagent with the acceptance criteria; you get back the verdict, not the screenshots.
4. If the task turns out bigger or harder than briefed, tell the coordinator what you
   learned rather than grinding on. Two compactions on one ticket is that signal: write a
   short handoff note in the worktree and ask the coordinator to split the ticket or start a
   fresh worker from the note.
5. Check coordinator messages after a test run and right before `worker_done`.
6. Open one PR (use the `pr` skill): `Closes #<n>`, acceptance criteria ticked. Leave
   merging to Daniel.
7. Send `worker_done`: three-sentence summary plus the PR link, details in a report file via
   `--report-path`. Then idle.
8. Questions go through `orca orchestration ask`; interactive prompts stall a worker.

## 3. Handoff (ownership transfer or a fresh session)

- Write the handoff to a durable place, outside the session scratchpad (it's deleted):
  `~/.<project>-coordinator/HANDOFF.md` for coordinators, or `~/.<project>-handoffs/<topic>.md`.
- Sections:
  1. The original brief, verbatim.
  2. Standing user decisions and preferences.
  3. Orca state: Run id, active dispatches, worker terminals.
  4. Repo state: branches, open PRs, uncommitted work.
  5. Environments: staging and prod URLs, credentials *locations* (never values).
  6. Open items for Daniel.
  7. **START HERE**: the next 3–5 concrete steps.
- Coordinators append a dated notes section at every wave boundary, so the file is always
  ready.
- Spawn the new owner with `orca-cli` (new worktree or terminal, `--agent claude`) and keep
  the prompt to a pointer: "You are taking over X. Read <file> in full first, especially
  START HERE. Preserve existing uncommitted work."

## 4. QA sweep

1. **Verify** on staging with `playwright-cli`. File one issue per
   defect with: Area, Severity rationale, How established, Steps to reproduce, Expected,
   Actual, Evidence, Suggested direction, and an "Agent brief". Label it `ready-for-agent`.
2. **Fix**: a coordinator dispatches `qa-fix-<n>` builders (section 1).
3. **Re-verify**: a `qa-verify-<n>` session confirms each fix on staging
   and closes the issue, or reopens it with evidence.

## 5. Decision gates and questions for Daniel

- Ask in one message, numbered `Q1…Qn`, with lettered options `(a)/(b)/(c)` and **your
  recommendation marked on each**. Daniel usually replies "Q1 a, Q2 b…" or "agree with all
  your recommendations".
- If he agrees with everything, proceed through all of it without asking again.
- Record lasting decisions as an ADR (when the ticket asks for one) and in the handoff
  file's standing decisions.

## Daniel's standing preferences

- Do it yourself: run commands, use `computer-use` for GUI-only steps (router pages,
  dashboards, credentials from his browser).
- Fix dependencies properly (update to a release that has the fix) rather than patching
  `node_modules` or vendored code locally.
- Use the `cf` CLI for Cloudflare unless the project has a Wrangler config.
- Clean up after yourself: release workers, remove merged worktrees, delete temp files.
