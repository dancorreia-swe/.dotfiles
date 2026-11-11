---
name: t3-workflow
description: Guide for spending tokens well in T3 Code — matching model, effort and helper roles (planner, strategist, designer, QA, advisor, reviewer, diagnoser) to how hard a task is. Sits alongside T3's own orchestration without changing it. Load in a T3 Code thread (t3_* or delegate_task tools available) when choosing a model or deciding whether a task needs helpers; also when driving T3 from a shell with the `t3` CLI.
---

# T3 Code: picking model, effort and helpers

T3's orchestration decides how agents flow: when and how to delegate, fork, isolate, wait and
hand off. Use it as designed. This skill only helps with the choices it leaves open: **how
hard is this task, does it need helpers, and which model and effort fit each one.**

The guide is shared with Orca: `~/.agents/skills/orca-workflow/references/roles.md`. In
short:

- **Most tasks need no helpers.** XS and S work is one agent on a light or mid model. Helpers
  start paying off at M (a planning pass, a QA pass) and L (planner, designer, reviewer).
  Risky areas (auth, payments, migrations, data deletion, security) earn an advisor and a
  second-family reviewer at any size.
- **Name the model and effort when delegating.** A child with no model inherits yours, so an
  Opus thread quietly spawns Opus children. Valid ids come from `orchestrator_capabilities`.
  Defaults: Haiku/low for mechanical work (rebases, re-checks, summaries); Sonnet/medium for
  building, QA and routine review; Codex at medium unless the piece is hard; Opus/high only
  for coordinating, planning, and reviewing risky changes. "High" effort is the exception,
  not the default.
- **Step up on evidence.** Haiku → Sonnet → Opus as the work pushes back; Codex for a second
  opinion; Fable only as an advisor on extra-hard calls.
- **QA loops go to a helper.** Emulator, simulator or browser checking (tap → look → tap)
  runs as `delegate_task` role `test` (Sonnet; Haiku for re-checks), reading
  `orca emulator ax --json` before screenshots, and returns pass/fail per criterion. A hook
  nudges a Claude thread at 8 device calls and stops it at 20.
- **Fresh orchestrator per phase.** An orchestrator's context grows with every child result;
  past ~200k, or at a phase boundary, write a handoff file and continue in a new thread
  started from it.
- **Brief narrowly, ask for short answers.** A helper with a focused brief that replies in a
  few lines (detail in a file) keeps the parent's context small.

**Host check:** T3 is the host whenever its tools are available, even if `ORCA_*` env vars are
set (inherited from an Orca terminal). Orca's `orchestration` and `orca-workflow` skills apply
only if Daniel names Orca.

**From a shell:** `t3 thread start|send|show` (see `--help`) accept `--provider` and
`--model`; the same guide applies.

**Questions for Daniel:** one message, `Q1…Qn`, lettered options, a recommendation on each.
