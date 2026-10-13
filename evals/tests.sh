#!/usr/bin/env bash
# Checks every eval case is well formed, and tests each case's check against made-up session logs,
# so a broken check cannot spend real runs. Spends nothing.
#   bash evals/tests.sh
set -u
cd "$(dirname "$0")/.." || exit 2
root=$PWD
pass=0 fails=""
ok() { pass=$((pass + 1)); }
bad() { fails="$fails
  FAIL: $1"; }
T=$(mktemp -d) && trap 'rm -rf "$T"' EXIT

for f in evals/cases/*.sh; do
  c=$(basename "$f" .sh)
  # shellcheck source=/dev/null
  if (. "$f" && [ -n "$PLUGIN" ] && [ -d "plugins/$PLUGIN" ] && [ -n "$PROMPT" ] && [ -n "$MODEL" ] && [ -n "$TURNS" ] &&
    [ -n "$WITH" ] && declare -F setup >/dev/null && declare -F check >/dev/null); then ok; else bad "$c is missing a field or function"; fi
  for p in $( . "$f"; echo "$WITH $WITHOUT"); do [ -d "plugins/$p" ] || bad "$c loads plugins/$p, which does not exist"; done
done

# run_check <case> <file with made-up log lines> [setup command run in the folder first]
run_check() {
  local d="$T/$1-$RANDOM"
  mkdir -p "$d" && (cd "$d" && eval "${3:-true}" && . "$root/evals/cases/$1.sh" && TRANSCRIPT=$2 check)
}
expect() { # expect <pass|fail> <name> <command...>
  local want=$1 name=$2; shift 2
  if "$@" >/dev/null 2>&1; then got=pass; else got=fail; fi
  [ "$got" = "$want" ] && ok || bad "$name: wanted $want, got $got"
}
log() { printf '%s\n' "$@" >"$T/log.jsonl"; echo "$T/log.jsonl"; }
read_call() { printf '{"type":"assistant","parent_tool_use_id":null,"message":{"content":[{"type":"tool_use","id":"%s","name":"Read","input":{"file_path":"/p/package-lock.json"%s}}]}}' "$1" "$2"; }
result() { printf '{"type":"user","message":{"content":[{"type":"tool_result","tool_use_id":"%s","is_error":%s,"content":"x"}]}}' "$1" "$2"; }
call() { printf '{"type":"assistant","parent_tool_use_id":null,"message":{"content":[{"type":"tool_use","id":"%s","name":"%s","input":%s}]}}' "${3:-t}" "$1" "$2"; }

expect pass "encoding: utf-8 given" run_check stacks-python-encoding /dev/null "printf 'open(p, encoding=\"utf-8\")\n' >util.py"
expect fail "encoding: none given" run_check stacks-python-encoding /dev/null "printf 'open(p)\n' >util.py"
expect fail "encoding: no file" run_check stacks-python-encoding /dev/null

expect fail "heavy file: a whole read that returned the file" run_check core-heavy-file-guard "$(log "$(read_call r1 '')" "$(result r1 false)")"
expect pass "heavy file: a whole read the guard refused" run_check core-heavy-file-guard "$(log "$(read_call r1 '')" "$(result r1 true)")"
expect pass "heavy file: a line-range read" run_check core-heavy-file-guard "$(log "$(read_call r1 ',"limit":40')" "$(result r1 false)")"
expect pass "heavy file: no read at all" run_check core-heavy-file-guard "$(log '{"type":"result","total_cost_usd":0.01}')"

expect pass "dispatch: progress note, then product" run_check core-role-dispatch "$(log "$(call Write '{"file_path":"/p/progress/now.md"}')" "$(call Agent '{"subagent_type":"sdlc-lean:product"}')")"
expect fail "dispatch: step file written first" run_check core-role-dispatch "$(log "$(call Write '{"file_path":"/p/plan/steps/S1.md"}')" "$(call Agent '{"subagent_type":"sdlc-lean:product"}')")"
expect pass "dispatch: a refused step write, then product" run_check core-role-dispatch "$(log "$(call Write '{"file_path":"/p/plan/steps/S1.md"}' w1)" "$(result w1 true)" "$(call Agent '{"subagent_type":"sdlc-lean:product"}')")"
expect fail "dispatch: builder before product" run_check core-role-dispatch "$(log "$(call Agent '{"subagent_type":"sdlc-lean:builder"}')")"
expect fail "dispatch: nothing happened" run_check core-role-dispatch "$(log '{"type":"result"}')"

if [ -n "$fails" ]; then
  echo "eval tests: $pass passed, $(printf '%s' "$fails" | grep -c FAIL) failed:$fails"
  exit 1
fi
echo "eval tests: $pass passed"
