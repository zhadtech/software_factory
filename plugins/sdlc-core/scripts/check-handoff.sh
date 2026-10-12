#!/usr/bin/env bash
# SubagentStop: a role agent listed in handoff_agents must end with the handoff block.
# When the block is missing or incomplete, the agent is kept running and told what to add.
. "$(dirname "$0")/lib.sh"
[ "$(input '.stop_hook_active // false')" = true ] && exit 0
agent=$(input '.agent_type // empty')
config '.handoff_agents // [] | .[]' | grep -qxF "${agent##*:}" || exit 0

msg=$(input '.last_assistant_message // ""')
missing=""
for key in STATUS STEP ARTIFACTS VERIFY DECISIONS OPEN NEXT; do
  printf '%s\n' "$msg" | grep -q "^$key:" || missing="$missing $key"
done
bad_status=""
if printf '%s\n' "$msg" | grep -q '^STATUS:' && ! printf '%s\n' "$msg" | grep -qE '^STATUS: (done|partial|blocked)( |$)'; then
  bad_status=1
fi
[ -z "$missing" ] && [ -z "$bad_status" ] && exit 0

reason="End with the handoff block, one field per line:
STATUS: done | partial | blocked
STEP: <step id>
ARTIFACTS: <paths created or changed>
VERIFY: <command you ran> -> <one-line real result>
DECISIONS: <calls made in your role, or none>
OPEN: <questions for the director, or none>
NEXT: <which role moves next and why>"
[ -n "$missing" ] && reason="Missing:$missing. $reason"
[ -n "$bad_status" ] && reason="STATUS must be done, partial or blocked. $reason"
jq -n --arg r "$reason" '{decision: "block", reason: $r}'
