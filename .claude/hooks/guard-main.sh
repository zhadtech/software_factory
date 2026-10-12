#!/usr/bin/env bash
# PreToolUse on Bash, for agents working on the factory itself.
# Pushes to main, force pushes and merges are Zhad's (CHARTER.md), so they are denied here.
# GitHub branch protection needs GitHub Pro on a private repo; this hook stands in for it.
# Covers Claude Code agents only; Zhad's own terminal is not affected.
cmd=$(jq -r '.tool_input.command // empty')
[ -n "$cmd" ] || exit 0

deny() {
  jq -n --arg r "$1 Pushes to main, force pushes and merges are Zhad's (CHARTER.md). Push a branch and open a draft pull request; Zhad merges it." \
    '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "deny", permissionDecisionReason: $r}}'
  exit 0
}

# Only a git or gh that starts a command counts: at a line start or after ; & | or (.
# So "echo git push origin main" passes. Text-based, so a quoted "&& git push origin main" still trips it.
at_start='(^|[;&|(])[[:space:]]*'
if printf '%s' "$cmd" | grep -qE "${at_start}gh[[:space:]]+pr[[:space:]]+merge([[:space:]]|$)"; then
  deny "Blocked: gh pr merge."
fi
if printf '%s' "$cmd" | grep -qE "${at_start}gh[[:space:]]+api([[:space:]].*)?/merges?([[:space:]]|$)"; then
  deny "Blocked: a merge through the GitHub API."
fi
# Each git push in the command, up to the next ; & or |.
pushes=$(printf '%s' "$cmd" | grep -oE "${at_start}git([[:space:]]+-C[[:space:]]+[^[:space:];&|]+)?[[:space:]]+push([[:space:]][^;&|]*)?")
[ -n "$pushes" ] || exit 0
while IFS= read -r push; do
  if printf '%s' "$push" | grep -qE '[[:space:]](-f|--force|--force-with-lease(=[^[:space:])]*)?|--mirror|--all|--delete|-d)([[:space:])]|$)|[[:space:]]\+'; then
    deny "Blocked: a force, mirror, all-branches or delete push."
  fi
  if printf '%s' "$push" | grep -qE '([[:space:]]|:)(refs/heads/)?main([[:space:])]|$)'; then
    deny "Blocked: a push to main."
  fi
done <<EOF
$pushes
EOF
# A bare push from main pushes main.
dir=${CLAUDE_PROJECT_DIR:-.}
if [ "$(git -C "$dir" branch --show-current 2>/dev/null)" = main ]; then
  deny "Blocked: a push while main is checked out."
fi
exit 0
