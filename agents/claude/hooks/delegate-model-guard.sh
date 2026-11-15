#!/usr/bin/env bash
# PreToolUse(mcp__t3-code__delegate_task): a T3 delegation must name target.model,
# otherwise the child inherits the parent's model (often Opus). DELEGATE_MODEL_GUARD=0 disables.
set -u
input=$(cat)
[ "${DELEGATE_MODEL_GUARD:-1}" = "0" ] && exit 0
model=$(printf '%s' "$input" | jq -r '.tool_input.target.model // empty' 2>/dev/null)
[ -n "$model" ] && exit 0
jq -n --arg r "Delegate model guard: this delegate_task names no target.model, so the child would inherit this thread's model. Size the task with the coordinating skill (~/.agents/skills/coordinating/SKILL.md, sections 1-2), take the id from orchestrator_capabilities, and set target.model (effort in target.options): Haiku/low for mechanical work and re-checks, Sonnet/medium for building, QA and review, Opus/high only for planning, advice and Risky review. Opus is fine when chosen on purpose; just name it." \
  '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$r}}'
