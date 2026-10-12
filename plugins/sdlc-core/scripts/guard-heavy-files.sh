#!/usr/bin/env bash
# PreToolUse on Read: denies a whole-file read of a heavy file. A read with a line limit passes.
# Patterns come from heavy_files in .claude/sdlc.json; * matches across folders.
# Start Claude Code with ALLOW_HEAVY_READ=1 to turn the guard off.
. "$(dirname "$0")/lib.sh"
[ "${ALLOW_HEAVY_READ:-0}" = 1 ] && exit 0
file=$(input '.tool_input.file_path // empty')
[ -n "$file" ] && [ -z "$(input '.tool_input.limit // empty')" ] || exit 0
rel=$(relpath "$file")

while IFS= read -r pattern; do
  [ -n "$pattern" ] || continue
  # shellcheck disable=SC2053  # the pattern is a glob on purpose
  if [[ $rel == $pattern ]]; then
    jq -n --arg p "$rel" '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "deny",
      permissionDecisionReason: ("Skipped a whole read of " + $p + ", a heavy file. Read a line range "
        + "(offset and limit), or query it: rg -n <term> " + $p + ", jq, or npm ls <package>. "
        + "If the task needs the whole file, say so in one line and stop.")}}'
    exit 0
  fi
done <<EOF
$(config '(.heavy_files // ["package-lock.json", "*/package-lock.json", "yarn.lock", "pnpm-lock.yaml",
  "node_modules/*", "*/node_modules/*", "*/Pods/*", "build/*", "dist/*", "docs/archive/*"]) | .[]')
EOF
exit 0
