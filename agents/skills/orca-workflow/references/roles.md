# Picking models, effort and helper roles (guide for Orca and T3 Code)

A guide, not a procedure. It answers three questions when an agent is about to spend tokens:
**how hard is this, which helpers (if any) does it need, and which model and effort should
each run on.** Everything else (how agents are spawned, placed, awaited, coordinated or handed
off) is the host app's design: Orca's orchestration, T3's orchestration, the agent's own
subagents. Follow that design as it is; use this guide inside it. When the guide and good
judgment in the moment disagree, judgment wins.

## How hard is it?

A quick read of the task, not a ceremony. The size suggests a crew; smaller is the default.

| Size | Typical signal | Usually enough |
|---|---|---|
| **XS** | Typo, copy, config value, dependency bump, rename. | The agent alone, light model. |
| **S** | Clear task, one area, testable as written. | The agent alone, mid model; it checks its own work. |
| **M** | Several files, or a gap in the spec. | A planning pass first, a QA pass after. |
| **L** | Cross-cutting, new feature, schema change, new UI surface. | A planner to split it; builders for the parts; a designer for UI; a strategist if scope or order is open; a reviewer per PR. |
| **Risky** (adds to any size) | Auth, payments, migrations, data deletion, secrets, security, public API. | An advisor before building, a second-family reviewer after. |
| **Unknown-cause bug** | Something broken, cause unknown. | Diagnose first (`diagnosing-bugs`); build once the cause is reproduced. |

Helpers pay for themselves only at the size that calls for them: a planner or reviewer on an
XS/S task costs more and adds nothing. When torn between two sizes, start smaller and step
up if the work pushes back (the same check failing twice, or the task proving bigger).

## Which model and effort?

Cheapest tier that clears the bar; step up on evidence.

| Tier | Model | Effort | Good for |
|---|---|---|---|
| **Light** | `claude-haiku-5-5` | low | XS work, summarising logs or CI output, mechanical sweeps, scripted re-checks, fact-gathering. |
| **Mid** (default) | `claude-sonnet-5-5` | medium | S/M building, QA, tests, applying a design system, routine review. |
| **Heavy** | `claude-opus-5-5` | high | Coordinating, planning, strategy, advice, diagnosis, L building, review of risky changes. |
| **Top** | `claude-fable-5-2` | high | Advisor on extra-hard calls only: an irreversible one-shot decision, heavy-tier advisor and second-family reviewer disagreeing, or a problem a heavy-tier attempt couldn't crack. |
| **Second family** | Codex `gpt-6.1-sol` | — | A second opinion (review, advice) that catches different things; also solid for backend/algorithmic S/M building. |

- Children usually inherit the parent's model when none is named, so a heavy coordinator
  quietly spawns heavy helpers. Naming the model is the single biggest saving.
- Helpers default to the agent's own subagents. An Orca worker or T3 thread fits when the
  helper needs its own worktree, a different agent family, or must outlive the session.
- Model ids drift; the host's model list (Orca's picker or `--help`, T3's
  `orchestrator_capabilities`) is the source of truth.

## Helper roles

Pick by need; most tasks need none. Each helper works best with a narrow brief and a short
answer back (a few lines plus a file for the detail).

| Role | Reach for it when | Tier | Brief it with | Gets back |
|---|---|---|---|---|
| **Builder** | Something needs building. | By size | The task, acceptance criteria, constraints (glossary, ADRs, scope). | The change (PR/diff) and a short summary. |
| **Planner** | M/L, or the path isn't obvious. | Heavy | The task, the ADRs, the code area. Read-only. | A one-page plan: files, steps, tests, risks; for L, the split into smaller tasks. |
| **Strategist** | Ordering a backlog, cutting scope, more candidates than capacity. | Heavy | Objective, candidates, constraints. Product docs, not code. | Recommended order and cuts; open choices as a `Q1…Qn` brief for Daniel. |
| **Designer** | New or changed UI. | Mid; heavy for a new pattern | The flow, the design system, affected screens. | A short UI spec covering empty/loading/error/success, or a throwaway prototype. |
| **QA** | Acceptance needs checking in a running app, emulator or suite; always for tap/screenshot loops, which bloat the builder's context. | Mid; light for re-checks | Acceptance criteria, where to run them, device id. Accessibility tree (`orca emulator ax --json`) before screenshots. | Pass/fail per criterion with evidence paths. |
| **Advisor** | A risky or ADR-level choice, or a builder stuck twice. | Heavy or second family; Top for extra-hard | The question, options, constraints and code, without your preferred answer. | A short verdict: the pick, why, and the risk that would change it. |
| **Reviewer** | A PR worth a second look (always for L or Risky). | Mid; heavy or second family when risky | The PR diff, the task, repo standards (`code-review`); app checks belong to QA. A re-review gets only the new commits plus the earlier findings. | Findings by severity, then approve / changes-needed. |
| **Diagnoser** | Bug with unknown cause. | Heavy | Symptoms and repro hints (`diagnosing-bugs`). | Root cause, a failing test, suggested fix. |
