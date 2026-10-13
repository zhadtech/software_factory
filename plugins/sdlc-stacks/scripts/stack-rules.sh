#!/usr/bin/env bash
# PreToolUse on Read|Edit|Write|NotebookEdit: the first time in a session that Claude touches a
# file a stack rule covers, adds that rule. A read gets the rules as added context. An edit is
# denied once, with the rules as the reason, so Claude makes it again with the rules in view.
# Rules and stacks come from rules.json, which scripts/build-stacks.rb writes from the registry.
# A stack is on when one of its markers matches a project file; a stack with no markers is
# always on. In every pattern, * also matches across folders.
command -v jq >/dev/null 2>&1 || exit 0
input=$(cat)
field() { printf '%s' "$input" | jq -r "$1"; }
dir=${CLAUDE_PROJECT_DIR:-$(field '.cwd // empty')}
file=$(field '.tool_input.file_path // .tool_input.notebook_path // empty')
[ -n "$dir" ] && [ -n "$file" ] || exit 0
case $file in "$dir"/*) rel=${file#"$dir"/} ;; /*) exit 0 ;; *) rel=$file ;; esac
rules=${SDLC_STACKS_RULES:-"$(dirname "$0")/../rules.json"}
state="${CLAUDE_PLUGIN_DATA:-${TMPDIR:-/tmp}/sdlc-stacks}/sessions"
mkdir -p "$state" 2>/dev/null || exit 0
session=$(field '.session_id // "none"')
on="$state/$session.stacks" seen="$state/$session.seen"
glob='def glob: "^" + (gsub("(?<c>[.+^$(){}|\\[\\]\\\\])"; "\\\(.c)") | gsub("[*]"; ".*") | gsub("[?]"; ".")) + "$";'

# Which stacks are on, worked out once per session. jq turns each marker into a regular
# expression once; grep then scans the project's file list, which stays fast on large repos.
if [ ! -f "$on" ]; then
  find "$state" -type f -mtime +7 -delete 2>/dev/null
  list="$state/$session.files"
  (cd "$dir" && { git ls-files -co --exclude-standard 2>/dev/null || find . -type f -not -path './.git/*' -not -path '*/node_modules/*' | sed 's#^\./##'; }) >"$list"
  jq -r "$glob"'.stacks[] | if (.markers | length) == 0 then .id
    else .id as $id | .markers[] | "\($id)\t\(.file | glob)\t\(.contains // "")" end' "$rules" |
    while IFS="$(printf '\t')" read -r id re contains; do
      if [ -z "$re" ]; then
        echo "$id"
      elif [ -z "$contains" ]; then
        grep -Eq -- "$re" "$list" && echo "$id"
      else
        grep -E -- "$re" "$list" | while IFS= read -r path; do
          grep -qF -- "$contains" "$dir/$path" 2>/dev/null && { echo "$id"; break; }
        done
      fi
    done | sort -u >"$on"
  rm -f "$list"
fi
touch "$seen"

new=$(jq -c --arg rel "$rel" --rawfile on "$on" --rawfile seen "$seen" "$glob"'
  ($on | split("\n")) as $on | ($seen | split("\n")) as $seen
  | [.rules[] | select(.stack as $s | any($on[]; . == $s)) | select(.id as $i | any($seen[]; . == $i) | not)
      | select(any(.paths[]; . as $p | $rel | test($p | glob)))]
  | {ids: map(.id), text: (map("**\(.id).** \(.text)") | join("\n"))}' "$rules") || exit 0
[ "$(printf '%s' "$new" | jq '.ids | length')" -gt 0 ] || exit 0
printf '%s' "$new" | jq -r '.ids[]' >>"$seen"
text=$(printf '%s' "$new" | jq -r .text)

if [ "$(field '.tool_name // empty')" = Read ]; then
  jq -n --arg t "Stack rules for $rel (sdlc-stacks; each is shown once per session):
$text" '{hookSpecificOutput: {hookEventName: "PreToolUse", additionalContext: $t}}'
else
  jq -n --arg t "Before you change $rel, apply these stack rules (sdlc-stacks; each is shown once per session). Then make the change again:
$text" '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "deny", permissionDecisionReason: $t}}'
fi
