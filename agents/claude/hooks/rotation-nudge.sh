#!/usr/bin/env bash
# PostToolUse(*): nudges the main agent to write its handoff and rotate (CLAUDE.md, Context hygiene).
# Fires once when context reaches ROTATE_TOKENS (default 190000), then every further 20k, and once
# at ROTATE_ROUNDS orchestration rounds (default 25: `orca orchestration check` calls plus
# delegate_task calls), then every further 10. Main agent only. ROTATION_NUDGE=0 disables.
set -u
input=$(cat)
[ "${ROTATION_NUDGE:-1}" = "0" ] && exit 0
[ -n "$(printf '%s' "$input" | jq -r '.agent_id // empty' 2>/dev/null)" ] && exit 0
sid=$(printf '%s' "$input" | jq -r '.session_id // "unknown"' 2>/dev/null)
f="${TMPDIR:-/tmp}/rotation-nudge-${sid}"
{ read -r rounds tok_band round_band < "$f"; } 2>/dev/null || { rounds=0; tok_band=0; round_band=0; }

tool=$(printf '%s' "$input" | jq -r '.tool_name // empty' 2>/dev/null)
cmd=$(printf '%s' "$input" | jq -r '.tool_input | if type == "object" then (.command // .cmd // .input // "") else (. // "") end | if type == "array" then join(" ") else tostring end' 2>/dev/null)
if [[ $tool =~ ^mcp__t3[-_]code__delegate_task$ ]] ||
   { [ "$tool" = "Bash" ] && printf '%s' "$cmd" | grep -Eq 'orca[[:space:]]+orchestration[[:space:]]+check'; }; then
  rounds=$((rounds + 1))
fi

tokens=0
tp=$(printf '%s' "$input" | jq -r '.transcript_path // empty' 2>/dev/null)
if [ -n "$tp" ] && [ -r "$tp" ]; then
  # Claude transcript: assistant usage; Codex rollout: token_count events (input_tokens includes cached)
  tokens=$(tail -n 40 "$tp" | jq -r '
    if .type == "assistant" and (.isSidechain | not) then .message.usage | select(. != null)
      | (.input_tokens // 0) + (.cache_read_input_tokens // 0) + (.cache_creation_input_tokens // 0)
    elif .type == "event_msg" and .payload.type == "token_count" then .payload.info.last_token_usage.input_tokens // empty
    else empty end' 2>/dev/null | tail -n 1)
  tokens=${tokens:-0}
fi

limit_t=${ROTATE_TOKENS:-190000}; limit_r=${ROTATE_ROUNDS:-25}
msg=""
if [ "$tokens" -ge "$limit_t" ]; then
  band=$(( (tokens - limit_t) / 20000 + 1 ))
  [ "$band" -gt "$tok_band" ] && { tok_band=$band; msg="context is at ~$((tokens / 1000))k tokens"; }
fi
if [ "$rounds" -ge "$limit_r" ]; then
  band=$(( (rounds - limit_r) / 10 + 1 ))
  [ "$band" -gt "$round_band" ] && { round_band=$band; msg="${msg:+$msg and }this session has run $rounds orchestration rounds"; }
fi
echo "$rounds $tok_band $round_band" > "$f"
[ -z "$msg" ] && exit 0
jq -n --arg c "Rotation nudge: $msg. Rotate, don't compact: finish the current step, write the handoff file (path and sections: coordinating skill section 6), then stop and tell Daniel to start a fresh session from it." \
  '{hookSpecificOutput:{hookEventName:"PostToolUse",additionalContext:$c}}'
exit 0
