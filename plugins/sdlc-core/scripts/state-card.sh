#!/usr/bin/env bash
# SessionStart: prints a short state card, which Claude Code adds to the session's context.
# It replaces the boot reads of the progress log and the plan.
. "$(dirname "$0")/lib.sh"
cd "$SDLC_DIR" || exit 0

now=$(config '.paths.now // "progress/now.md"')
waiting=$(config '.paths.waiting // "progress/waiting.md"')
queue=$(config '.paths.queue // "plan/queue.json"')
director=$(config '.director // "the director"')

branch=$(git branch --show-current 2>/dev/null)
dirty=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
verify=$(head -1 .verify/last-result 2>/dev/null)
next=$("$SDLC_BIN/next-step" "$queue" 2>&1)
asks=0
[ -f "$waiting" ] && asks=$(grep -cE '^([0-9]+\.|-) ' "$waiting")
if budget=$("$SDLC_BIN/sdlc-budget" 2>&1); then budget="all files within budget"; else budget=$(printf '%s' "$budget" | head -5); fi

echo "State card (sdlc-core). Act from this; do not re-read the plan or the log to orient."
echo "- Branch: ${branch:-none}, ${dirty} uncommitted file(s)"
echo "- Last verify: ${verify:-no run recorded}"
echo "- Next ready step: $next"
echo "- Questions waiting on $director: $asks (in $waiting)"
echo "- Size budgets: $budget"
if [ -f "$now" ]; then
  echo
  echo "$now:"
  head -20 "$now"
fi
if [ "$(input '.source // empty')" = compact ] && [ -f .claude/out/snapshot.md ]; then
  echo
  cat .claude/out/snapshot.md
fi
exit 0
