#!/usr/bin/env bash
# PostToolUse on Edit|Write: when the edit touched plan/queue.json, checks it against
# schemas/queue.schema.json (required fields, unknown fields, allowed values, the step id pattern)
# and tells Claude what to fix. next-step skips a step it cannot read, so a bad entry hides silently.
. "$(dirname "$0")/lib.sh"
queue=$(config '.paths.queue // "plan/queue.json"')
[ "$(relpath "$(input '.tool_input.file_path // empty')")" = "$queue" ] || exit 0
schema="$(dirname "$0")/../schemas/queue.schema.json"

problems=$(jq -r --slurpfile s "$schema" '
  $s[0] as $top | $top.properties.steps.items as $item
  | def check($obj; $sch; $name):
      ($sch.required - ($obj | keys) | map("\($name)missing \(.)")),
      (($obj | keys) - ($sch.properties | keys) | map("\($name)unknown field \(.)")),
      [$obj | to_entries[] | . as $f | $sch.properties[$f.key] // {} | select(.enum)
        | select(any(.enum[]; . == $f.value) | not)
        | "\($name)\($f.key) is \($f.value | tojson); it must be one of \(.enum | join(", "))"],
      [$obj | to_entries[] | . as $f | $sch.properties[$f.key] // {} | select(.pattern) | .pattern as $p
        | select(($f.value | type) != "string" or ($f.value | test($p) | not))
        | "\($name)\($f.key) is \($f.value | tojson); it must match \($p)"];
  [check(.; $top; ""),
   (if (.steps | type) == "array" then .steps | to_entries[]
      | check(.value; $item; "\(.value.id // "step \(.key + 1)"): ") else empty end)]
  | flatten | .[]' "$SDLC_DIR/$queue" 2>&1) || problems="it could not be read: $problems"
[ -n "$problems" ] || exit 0
fields=$(jq -r '.properties.steps.items.properties | keys_unsorted | join(", ")' "$schema")
jq -n --arg q "$queue" --arg p "$problems" --arg f "$fields" '{decision: "block",
  reason: ($q + " does not match its schema (sdlc-core schemas/queue.schema.json):\n" + $p
    + "\nFix it before you go on. A step may have these fields: " + $f + ".")}'
