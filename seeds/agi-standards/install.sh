#!/usr/bin/env bash
# Drop the agent-standards kit into a project.
#   ./install.sh /path/to/project
# Existing files are never overwritten; they're reported and skipped.

set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST="${1:-$PWD}"

[ -d "$DEST" ] || { echo "no such directory: $DEST" >&2; exit 1; }

copy() {
  local from="$1" to="$DEST/$2"
  if [ -e "$to" ]; then
    echo "  skip   $2 (already exists)"
  else
    cp "$from" "$to"
    echo "  add    $2"
  fi
}

echo "installing agent standards into $DEST"
copy "$SRC/AGENTS.md"            AGENTS.md
copy "$SRC/CLAUDE.md"            CLAUDE.md
copy "$SRC/templates/INDEX.md"   INDEX.md
copy "$SRC/templates/PLAN.md"    PLAN.md
copy "$SRC/templates/PROGRESS.md" PROGRESS.md

cat <<'NOTE'

next:
  1. fill in section 8 of AGENTS.md (the project commands) — 5 minutes, highest payoff
  2. have the agent generate INDEX.md from the real tree, then correct it by hand
  3. write PLAN.md for the first task before any code
NOTE
