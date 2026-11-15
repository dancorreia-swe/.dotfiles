#!/usr/bin/env bash
# PreToolUse(Bash|mcp__t3[-_]code__device_screenshot) guard: keeps emulator/simulator tap loops out of the
# main agent's context. Counts Orca emulator input, simctl io, adb input, T3 agent-device input and
# T3 device_screenshot calls. Main agent only (subagents carry agent_id and pass straight through).
# Nudge at EMU_QA_NUDGE calls per session, deny from EMU_QA_BLOCK on. EMU_QA_GUARD=0 disables.
set -u
input=$(cat)
[ "${EMU_QA_GUARD:-1}" = "0" ] && exit 0
agent_id=$(printf '%s' "$input" | jq -r '.agent_id // empty' 2>/dev/null)
[ -n "$agent_id" ] && exit 0
tool=$(printf '%s' "$input" | jq -r '.tool_name // empty' 2>/dev/null)
if ! [[ $tool =~ ^mcp__t3[-_]code__device_screenshot$ ]]; then # `-` in Claude, maybe `_` in Codex
  cmd=$(printf '%s' "$input" | jq -r '.tool_input | if type == "object" then (.command // .cmd // .input // "") else (. // "") end | if type == "array" then join(" ") else tostring end' 2>/dev/null)
  printf '%s' "$cmd" | grep -Eq \
    -e 'orca[[:space:]]+emulator[[:space:]]+(tap|type|gesture|button|swipe)' \
    -e 'xcrun[[:space:]]+simctl[[:space:]]+io' \
    -e 'adb([[:space:]]+-s[[:space:]]+[^[:space:]]+)?[[:space:]]+shell[[:space:]]+input' \
    -e 'agent-device[^|;&]*[[:space:]](press|click|fill|longpress|hover|scroll|back|type|swipe|gesture|focus|find|keyboard|alert|home|app-switcher|hardware-button|action-button|tv-remote|batch)([[:space:]]|$)' \
    || exit 0
fi
sid=$(printf '%s' "$input" | jq -r '.session_id // "unknown"' 2>/dev/null)
f="${TMPDIR:-/tmp}/emu-qa-guard-${sid}"
[ -e "$f.qa" ] && exit 0   # session declared itself a dedicated QA agent
n=$(( $(cat "$f" 2>/dev/null || echo 0) + 1 ))
echo "$n" > "$f"
nudge=${EMU_QA_NUDGE:-8}; block=${EMU_QA_BLOCK:-20}
helper="Hand the remaining checks to a fresh-context QA helper: in T3 Code an Agent subagent (or delegate_task for another provider) given the device hostId and id, told to call device_open itself; in Orca a qa-verify worker. Model sonnet, haiku for re-checks. Brief it with the acceptance criteria; ask for pass/fail per criterion plus evidence paths. Read UI state as text (agent-device diffs or snapshot -i, orca emulator ax --json) rather than screenshots."
qa="If this session IS the dedicated QA agent, run: touch $f.qa  and carry on."
if [ "$n" -ge "$block" ]; then
  jq -n --arg r "Emulator QA guard: $n device-interaction calls in the main agent. $helper $qa" \
    '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$r}}'
elif [ "$n" -eq "$nudge" ]; then
  jq -n --arg c "Emulator QA guard: $n device-interaction calls in the main agent; each cycle grows this context and calls are denied from $block. $helper $qa" \
    '{hookSpecificOutput:{hookEventName:"PreToolUse",additionalContext:$c}}'
fi
exit 0
