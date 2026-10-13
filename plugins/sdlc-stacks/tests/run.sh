#!/usr/bin/env bash
# Runs the sdlc-stacks hook against throwaway projects.
#   bash plugins/sdlc-stacks/tests/run.sh
# Prints one line when all pass; otherwise each failure, and exits 1.
set -u
PLUGIN="$(cd "$(dirname "$0")/.." && pwd)"
pass=0 fails=""
check() { # check <name> <condition command...>
  local name=$1; shift
  if "$@" >/dev/null 2>&1; then pass=$((pass + 1)); else fails="$fails
  FAIL: $name"; fi
}
has() { printf '%s' "$1" | grep -qF -- "$2"; }
empty() { [ -z "$1" ]; }
lacks() { ! has "$1" "$2"; }

T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT
export CLAUDE_PLUGIN_DATA="$T/data"
P="$T/project" && mkdir -p "$P/src" && git -C "$P" init -q
# hook <session> <tool> <path relative to the project, or absolute>
hook() {
  local f=$3
  case $f in /*) ;; *) f="$P/$f" ;; esac
  printf '{"session_id":"%s","tool_name":"%s","tool_input":{"file_path":"%s"}}' "$1" "$2" "$f" |
    CLAUDE_PROJECT_DIR=$P bash "$PLUGIN/scripts/stack-rules.sh"
}
context() { printf '%s' "$1" | jq -r '.hookSpecificOutput.additionalContext // empty'; }

# The real rules: Python has no markers, so its rules apply to any matching file.
out=$(hook s1 Read src/app.py)
check "a read of a .py file gets the Python rules" has "$(context "$out")" "R-PY-003"
check "the rules name the file" has "$(context "$out")" "Stack rules for src/app.py"
check "a read is not denied" lacks "$out" '"deny"'
check "rules for other files stay out" lacks "$out" "R-PY-006"
out=$(hook s1 Read src/other.py)
check "a rule is shown once per session" empty "$out"
out=$(hook s1 Edit tests/test_app.py)
check "a first edit of a test file is denied once" has "$out" '"permissionDecision": "deny"'
check "the denial carries the new rule" has "$out" "R-PY-006"
check "the denial leaves out rules already shown" lacks "$out" "R-PY-003"
out=$(hook s1 Edit tests/test_app.py)
check "the same edit then passes" empty "$out"
out=$(hook s2 Write src/app.py)
check "a new session shows the rules again" has "$out" "R-PY-001"
out=$(hook s3 Read README.md)
check "a file no rule covers gets nothing" empty "$out"
out=$(hook s3 Read /etc/hosts)
check "a file outside the project gets nothing" empty "$out"
out=$(hook s3 Read pyproject.toml)
check "a pattern without * matches the file at the root" has "$(context "$out")" "R-PY-002"

# Markers, with a rules file made for the test.
export SDLC_STACKS_RULES="$T/rules.json"
cat >"$SDLC_STACKS_RULES" <<'JSON'
{ "stacks": [
    { "id": "next", "title": "Next.js", "markers": [{ "file": "*package.json", "contains": "\"next\"" }] },
    { "id": "godot", "title": "Godot", "markers": [{ "file": "*project.godot" }] } ],
  "rules": [
    { "id": "R-NEXT-001", "stack": "next", "status": "proposed", "paths": ["*.tsx"], "text": "Next rule." },
    { "id": "R-GD-001", "stack": "godot", "status": "proposed", "paths": ["*.gd"], "text": "Godot rule." } ] }
JSON
out=$(hook m1 Read src/page.tsx)
check "a stack without its markers stays off" empty "$out"
printf '{ "dependencies": { "react": "19" } }\n' >"$P/package.json"
out=$(hook m2 Read src/page.tsx)
check "a marker file without its text leaves the stack off" empty "$out"
mkdir -p "$P/web" && printf '{ "dependencies": { "next": "16" } }\n' >"$P/web/package.json"
out=$(hook m3 Read web/app/page.tsx)
check "a marker in a subfolder turns the stack on" has "$(context "$out")" "R-NEXT-001"
check "other stacks stay off" lacks "$out" "R-GD-001"
mkdir -p "$P/game" && touch "$P/game/project.godot"
out=$(hook m3 Read game/player.gd)
check "stacks are worked out once per session" empty "$out"
out=$(hook m4 Read game/player.gd)
check "a marker without text turns its stack on" has "$(context "$out")" "R-GD-001"
out=$(hook m4 Read src/app.py)
check "a stack missing from the rules file adds nothing" empty "$out"

if [ -n "$fails" ]; then
  echo "sdlc-stacks tests: $pass passed, $(printf '%s' "$fails" | grep -c FAIL) failed:$fails"
  exit 1
fi
echo "sdlc-stacks tests: $pass passed"
