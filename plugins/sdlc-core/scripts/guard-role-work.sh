#!/usr/bin/env bash
# PreToolUse on Write|Edit|NotebookEdit|Bash (R-TEAM-003): when .claude/sdlc.json lists handoff_agents,
# the main session does no role work. It may write files that match main_session_writes
# (default: progress/* and plan/queue.json) and files outside the project, and it may not git commit.
# In the shell, writes through > , >> and tee count too; heredoc bodies and quoted text are skipped.
# Role agents are not affected: the hook input names them in agent_type.
# Remove handoff_agents from .claude/sdlc.json to let the main session do the work itself.
. "$(dirname "$0")/lib.sh"
[ -z "$(input '.agent_type // empty')" ] || exit 0
[ -n "$(config '.handoff_agents // [] | .[]')" ] || exit 0

deny() {
  next=$(cd "$SDLC_DIR" && "$SDLC_BIN/next-step" 2>/dev/null) || [ -n "$next" ] || next="unknown; the queue could not be read"
  jq -n --arg what "$1" --arg next "$next" '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "deny",
    permissionDecisionReason: ($what + " is role work, and the main session does no role work (R-TEAM-003, which the "
      + "director put in force for this project). Do not stop to ask whether to use the roles: call the Agent tool now. "
      + "A request with no step goes to the product role first (sdlc-lean:product in the lean team), which writes "
      + "the steps; the builder writes the code and commits. Next ready step: " + $next)}}'
  exit 0
}

# allowed <path>: true when the main session may write it.
allowed() {
  local rel pattern
  rel=$(relpath "$1")
  rel=${rel#./}
  case $rel in /*) return 0 ;; esac
  while IFS= read -r pattern; do
    [ -n "$pattern" ] || continue
    # shellcheck disable=SC2053  # the pattern is a glob on purpose
    [[ $rel == $pattern ]] && return 0
  done <<EOF
$(config '(.main_session_writes // ["progress/*", "plan/queue.json"]) | .[]')
EOF
  return 1
}

if [ "$(input '.tool_name // empty')" = Bash ]; then
  cmd=$(input '.tool_input.command // empty')
  # Only a git that starts a command counts, as in the factory's main-branch guard.
  printf '%s' "$cmd" | grep -qE '(^|[;&|(])[[:space:]]*git([[:space:]]+-C[[:space:]]+[^[:space:];&|]+)?[[:space:]]+commit([[:space:]]|$)' &&
    deny "A git commit"
  # The shell text that runs: heredoc bodies and quoted strings removed.
  shell=$(printf '%s\n' "$cmd" | awk '
    end != "" { if ($0 == end || $0 ~ "^[ \t]*" end "$") end = ""; next }
    { print; if (match($0, /<<-?[ \t]*["'"'"']?[A-Za-z_][A-Za-z0-9_]*/)) { end = substr($0, RSTART, RLENGTH); gsub(/^<<-?[ \t]*["'"'"']?/, "", end) } }' |
    sed -E "s/'[^']*'//g; s/\"[^\"]*\"//g")
  targets=$(
    printf '%s\n' "$shell" | grep -oE '(^|[^<>&0-9])>>?[[:space:]]*[^[:space:];&|<>()]+' | sed -E 's/^[^>]*>>?[[:space:]]*//'
    printf '%s\n' "$shell" | grep -oE '(^|[;&|(])[[:space:]]*tee([[:space:]]+-a)?[[:space:]]+[^[:space:];&|<>()-][^[:space:];&|<>()]*' | awk '{print $NF}'
  )
  while IFS= read -r t; do
    [ -n "$t" ] || continue
    case $t in /dev/* | \$* | \&*) continue ;; esac
    case $t in /*) f=$t ;; *) f="$SDLC_DIR/$t" ;; esac
    allowed "$f" || deny "Writing $(relpath "$f") from the shell"
  done <<EOF
$targets
EOF
  exit 0
fi

file=$(input '.tool_input.file_path // .tool_input.notebook_path // empty')
[ -n "$file" ] || exit 0
allowed "$file" || deny "Writing $(relpath "$file")"
exit 0
