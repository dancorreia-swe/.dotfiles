#!/usr/bin/env bash
# PreToolUse(Bash): an Orca launch of a claude/codex agent must name --model,
# otherwise it inherits the default (Opus 5.5 high). ORCA_MODEL_GUARD=0 disables.
set -u
input=$(cat)
[ "${ORCA_MODEL_GUARD:-1}" = "0" ] && exit 0
cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null)
printf '%s' "$cmd" | grep -Eq 'orca[[:space:]]+(orchestration[[:space:]]+worker-start|worktree[[:space:]]+create|agent[[:space:]]+launch)' || exit 0
printf '%s' "$cmd" | grep -Eq -- '--agent[= ]+["'"'"']?(claude|codex)\b' || exit 0
printf '%s' "$cmd" | grep -Eq -- '--model[= ]' && exit 0
jq -n --arg r "Orca model guard: this launches a claude/codex agent without --model, so it would inherit the default (Opus 5.5, high effort). Size the task with ~/.agents/skills/orca-workflow/references/roles.md and add --model (plus --effort), e.g. --model claude-sonnet-5-5 --effort medium for S/M builds, claude-haiku-5-5 --effort low for XS or re-checks, claude-opus-5-5 --effort high only for coordinators, planners, advisors and L work. Opus is fine when chosen on purpose; just name it." \
  '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$r}}'
