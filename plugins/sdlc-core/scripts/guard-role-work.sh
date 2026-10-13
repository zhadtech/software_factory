#!/usr/bin/env bash
# PreToolUse on Write|Edit|NotebookEdit|Bash (R-TEAM-003): when .claude/sdlc.json lists handoff_agents,
# the main session does no role work. It may write files that match main_session_writes
# (default: progress/* and plan/queue.json) and files outside the project, and it may not git commit.
# Role agents are not affected: the hook input names them in agent_type.
# Remove handoff_agents from .claude/sdlc.json to let the main session do the work itself.
. "$(dirname "$0")/lib.sh"
[ -z "$(input '.agent_type // empty')" ] || exit 0
[ -n "$(config '.handoff_agents // [] | .[]')" ] || exit 0

deny() {
  next=$(cd "$SDLC_DIR" && "$SDLC_BIN/next-step" 2>/dev/null) || [ -n "$next" ] || next="unknown; the queue could not be read"
  jq -n --arg what "$1" --arg next "$next" '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "deny",
    permissionDecisionReason: ($what + " is role work, and the main session does no role work (R-TEAM-003). "
      + "Hand it to the role that owns it with the Agent tool, such as sdlc-lean:builder: product writes the steps, "
      + "builder writes the code and commits. A request with no step goes to product first. Next ready step: " + $next)}}'
  exit 0
}

if [ "$(input '.tool_name // empty')" = Bash ]; then
  # Only a git that starts a command counts, as in the factory's main-branch guard.
  input '.tool_input.command // empty' |
    grep -qE '(^|[;&|(])[[:space:]]*git([[:space:]]+-C[[:space:]]+[^[:space:];&|]+)?[[:space:]]+commit([[:space:]]|$)' &&
    deny "A git commit"
  exit 0
fi

file=$(input '.tool_input.file_path // .tool_input.notebook_path // empty')
[ -n "$file" ] || exit 0
rel=$(relpath "$file")
case $rel in /*) exit 0 ;; esac
while IFS= read -r pattern; do
  [ -n "$pattern" ] || continue
  # shellcheck disable=SC2053  # the pattern is a glob on purpose
  [[ $rel == $pattern ]] && exit 0
done <<EOF
$(config '(.main_session_writes // ["progress/*", "plan/queue.json"]) | .[]')
EOF
deny "Writing $rel"
