#!/usr/bin/env bash
# PreCompact: writes .claude/out/snapshot.md (branch, step in progress, uncommitted changes)
# so the state card can show it after compaction. Never blocks compaction.
. "$(dirname "$0")/lib.sh"
cd "$SDLC_DIR" || exit 0
queue=$(config '.paths.queue // "plan/queue.json"')
mkdir -p .claude/out
{
  echo "Snapshot taken before compaction ($(input '.trigger // "unknown"'), $(date '+%Y-%m-%d %H:%M')):"
  echo "- Branch: $(git branch --show-current 2>/dev/null)"
  step=$(jq -r '[.steps[]? | select(.status == "in_progress") | "\(.id) \(.title)"] | join("; ")' "$queue" 2>/dev/null)
  echo "- Step in progress: ${step:-none marked in $queue}"
  echo "- Uncommitted changes:"
  git diff --stat HEAD 2>/dev/null | tail -15 | sed 's/^/    /'
} > .claude/out/snapshot.md
exit 0
