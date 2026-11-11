#!/usr/bin/env bash
# PreToolUse(Bash) guard: keeps emulator/simulator tap loops out of the main agent's context.
# Main agent only (subagents carry agent_id and pass straight through).
# Nudge at EMU_QA_NUDGE calls per session, deny from EMU_QA_BLOCK on. EMU_QA_GUARD=0 disables.
set -u
input=$(cat)
[ "${EMU_QA_GUARD:-1}" = "0" ] && exit 0
agent_id=$(printf '%s' "$input" | jq -r '.agent_id // empty' 2>/dev/null)
[ -n "$agent_id" ] && exit 0
cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null)
printf '%s' "$cmd" | grep -Eq 'orca[[:space:]]+emulator[[:space:]]+(tap|type|gesture|button|swipe)|xcrun[[:space:]]+simctl[[:space:]]+io|adb([[:space:]]+-s[[:space:]]+[^[:space:]]+)?[[:space:]]+shell[[:space:]]+input' || exit 0
sid=$(printf '%s' "$input" | jq -r '.session_id // "unknown"' 2>/dev/null)
f="${TMPDIR:-/tmp}/emu-qa-guard-${sid}"
[ -e "$f.qa" ] && exit 0   # session declared itself a dedicated QA agent
n=$(( $(cat "$f" 2>/dev/null || echo 0) + 1 ))
echo "$n" > "$f"
nudge=${EMU_QA_NUDGE:-8}; block=${EMU_QA_BLOCK:-20}
if [ "$n" -ge "$block" ]; then
  jq -n --arg f "$f" --arg r "Emulator QA guard: $n device-interaction calls in the main agent. Hand the rest of this QA loop to a fresh-context QA helper (Agent tool, or delegate_task role=test in T3 Code; model sonnet, haiku for re-checks) with the acceptance criteria and the device id; ask for pass/fail per criterion plus evidence paths. Prefer 'orca emulator ax --json' over screenshots. If this session IS the dedicated QA agent (e.g. an Orca qa-verify worker), run: touch $f.qa  and carry on." \
    '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$r}}'
elif [ "$n" -eq "$nudge" ]; then
  jq -n --arg c "Emulator QA guard: $n device-interaction calls so far in the main agent. Each tap/screenshot cycle grows this context. Delegate the remaining checks to a fresh-context QA helper (Agent tool, or delegate_task role=test in T3 Code; model sonnet, haiku for re-checks) and read 'orca emulator ax --json' instead of screenshots where you can. Further calls are denied at $block." \
    '{hookSpecificOutput:{hookEventName:"PreToolUse",additionalContext:$c}}'
fi
exit 0
