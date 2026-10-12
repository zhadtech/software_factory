#!/usr/bin/env bash
# PostToolUse on Edit|Write: when the edited file has a size budget and is now over it,
# tells Claude to trim it before going on.
. "$(dirname "$0")/lib.sh"
file=$(input '.tool_input.file_path // empty')
[ -n "$file" ] || exit 0
over=$(cd "$SDLC_DIR" && "$SDLC_BIN/sdlc-budget" "$(relpath "$file")") && exit 0
jq -n --arg o "$over" '{decision: "block",
  reason: ("This edit put a file over its size budget:\n" + $o + "\nTrim it back under the budget before you continue. Move finished or detailed material to its archive or detail file; do not delete facts.")}'
