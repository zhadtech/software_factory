#!/usr/bin/env bash
# Runs every sdlc-core hook and tool against a throwaway project.
#   bash plugins/sdlc-core/tests/run.sh
# Prints one line when all pass; otherwise each failure, and exits 1.
set -u
PLUGIN="$(cd "$(dirname "$0")/.." && pwd)"
S="$PLUGIN/scripts" B="$PLUGIN/bin"
pass=0 fails=""
check() { # check <name> <condition command...>
  local name=$1; shift
  if "$@" >/dev/null 2>&1; then pass=$((pass + 1)); else fails="$fails
  FAIL: $name"; fi
}
has() { printf '%s' "$1" | grep -qF -- "$2"; }
empty() { [ -z "$1" ]; }
lacks() { ! has "$1" "$2"; }

P=$(mktemp -d)
trap 'rm -rf "$P"' EXIT
export CLAUDE_PROJECT_DIR="$P"
hook() { printf '%s' "$2" | bash "$S/$1"; }

# Without .claude/sdlc.json every hook is a no-op.
for h in state-card.sh guard-heavy-files.sh guard-role-work.sh trim-output.sh budget-check.sh check-queue.sh check-handoff.sh snapshot-state.sh; do
  out=$(hook "$h" '{"tool_input":{"file_path":"'"$P"'/package-lock.json"},"agent_type":"builder"}'; echo "exit $?")
  check "$h is a no-op without config" [ "$out" = "exit 0" ]
done

# A configured project.
cd "$P" || exit 1
git init -q -b main . && git config user.email t@t && git config user.name t
mkdir -p .claude plan progress .verify docs/sdlc
cat > .claude/sdlc.json <<'JSON'
{
  "trim_lines": 120,
  "handoff_agents": ["builder", "reviewer"],
  "heavy_files": ["package-lock.json", "*/Pods/*", "docs/archive/*"],
  "budgets": [
    { "path": "progress/now.md", "max_lines": 15, "hint": "Keep only the next action." },
    { "path": "INDEX.md", "max_line_chars": 40 },
    { "path": "docs/*.md", "max_lines": 5, "unless": "size-reason:", "except": "docs/archive/*" }
  ]
}
JSON
cat > plan/queue.json <<'JSON'
{ "next_id": 5, "steps": [
  { "id": "S3", "title": "Blocked by S4", "owner": "builder", "tier": "M", "after": ["S4"], "status": "ready", "verify": "npm test" },
  { "id": "S4", "title": "Fog fades", "owner": "builder", "tier": "M", "status": "in_progress", "verify": "npm test" },
  { "id": "S2", "title": "Edge cells", "owner": "builder", "tier": "S", "after": ["S1"], "status": "ready", "verify": "npm test", "context": ["src/fog/CLAUDE.md"] }
] }
JSON
printf 'Next: finish S4.\n' > progress/now.md
printf '# Waiting\n\n1. First question?\n2. Second question?\n' > progress/waiting.md
printf 'pass 2026-10-13 10:00\n' > .verify/last-result
git add -A && git commit -qm init

# next-step
out=$("$B/next-step"); code=$?
check "next-step skips a step whose after-step is open" has "$out" "S2 · builder · tier S · Edge cells · read: src/fog/CLAUDE.md"
check "next-step exits 0 when a step is ready" [ $code -eq 0 ]
printf '{"next_id":1,"steps":[]}' > /tmp/sdlc-empty-$$.json
"$B/next-step" /tmp/sdlc-empty-$$.json >/dev/null; check "next-step exits 1 with no ready step" [ $? -eq 1 ]
rm -f /tmp/sdlc-empty-$$.json
"$B/next-step" nowhere.json >/dev/null; check "next-step exits 2 with no queue" [ $? -eq 2 ]

# state card
out=$(hook state-card.sh '{"source":"startup"}')
check "state card shows the branch" has "$out" "Branch: main, 0 uncommitted"
check "state card shows the last verify" has "$out" "Last verify: pass 2026-10-13"
check "state card shows the next step" has "$out" "Next ready step: S2"
check "state card counts waiting questions" has "$out" "waiting on the director: 2"
check "state card reports budgets" has "$out" "all files within budget"
check "state card includes now.md" has "$out" "Next: finish S4."

# heavy-file guard
out=$(hook guard-heavy-files.sh '{"tool_input":{"file_path":"'"$P"'/package-lock.json"}}')
check "guard denies a whole lockfile read" has "$out" '"permissionDecision": "deny"'
out=$(hook guard-heavy-files.sh '{"tool_input":{"file_path":"'"$P"'/docs/archive/v0.1/plan.md"}}')
check "guard denies a nested archive read" has "$out" "docs/archive/v0.1/plan.md"
out=$(hook guard-heavy-files.sh '{"tool_input":{"file_path":"'"$P"'/package-lock.json","offset":1,"limit":40}}')
check "guard allows a line-range read" empty "$out"
out=$(hook guard-heavy-files.sh '{"tool_input":{"file_path":"'"$P"'/package-lock.json","allow_large":true}}')
check "guard denies a whole read even with allow_large (Claude Code 2.1.296)" has "$out" '"permissionDecision": "deny"'
out=$(hook guard-heavy-files.sh '{"tool_input":{"file_path":"'"$P"'/src/app.ts"}}')
check "guard allows an ordinary file" empty "$out"
out=$(printf '%s' '{"tool_input":{"file_path":"'"$P"'/package-lock.json"}}' | ALLOW_HEAVY_READ=1 bash "$S/guard-heavy-files.sh")
check "ALLOW_HEAVY_READ=1 turns the guard off" empty "$out"

# output trimmer
long=$(seq 1 300 | sed 's/^150$/150 Error: boom/' | jq -Rs .)
out=$(hook trim-output.sh '{"tool_input":{"command":"npm test"},"tool_response":{"stdout":'"$long"',"stderr":"","interrupted":false,"isImage":false}}')
stdout=$(printf '%s' "$out" | jq -r '.hookSpecificOutput.updatedToolOutput.stdout')
check "trimmer shortens long output" has "$stdout" "[300 lines in total; full output saved to .claude/out/"
check "trimmer keeps error lines" has "$stdout" "150 Error: boom"
check "trimmer keeps the other output fields" [ "$(printf '%s' "$out" | jq -r '.hookSpecificOutput.updatedToolOutput.isImage')" = false ]
check "trimmer saves the full output" [ "$(cat .claude/out/bash-*.log | grep -c '^[0-9]')" -ge 300 ]
out=$(hook trim-output.sh '{"tool_input":{"command":"ls"},"tool_response":{"stdout":"a\nb","stderr":""}}')
check "trimmer leaves short output alone" empty "$out"
out=$(hook trim-output.sh '{"tool_input":{"command":"SDLC_FULL_OUTPUT=1 npm test"},"tool_response":{"stdout":'"$long"',"stderr":""}}')
check "SDLC_FULL_OUTPUT=1 keeps full output" empty "$out"

# size budgets
out=$(hook budget-check.sh '{"tool_input":{"file_path":"'"$P"'/progress/now.md"}}')
check "budget check passes a file within budget" empty "$out"
seq 1 20 > progress/now.md
out=$(hook budget-check.sh '{"tool_input":{"file_path":"'"$P"'/progress/now.md"}}')
check "budget check blocks an over-budget file" has "$out" '"decision": "block"'
check "budget check names the file and hint" has "$out" "progress/now.md: 20 lines (budget 15). Keep only the next action."
printf '| short |\n| %s |\n' "$(printf 'x%.0s' $(seq 1 50))" > INDEX.md
out=$("$B/sdlc-budget" INDEX.md); code=$?
check "sdlc-budget flags long lines" has "$out" "INDEX.md: 1 line(s) longer than 40 characters"
check "sdlc-budget exits 1 when over" [ $code -eq 1 ]
seq 1 9 > docs/sdlc/long.md
printf -- '---\nsize-reason: the threat model\n---\n%s\n' "$(seq 1 9)" > docs/sdlc/exempt.md
git add -A
out=$("$B/sdlc-budget")
check "sdlc-budget checks every budgeted file" has "$out" "docs/sdlc/long.md: 9 lines (budget 5)"
check "unless exempts a file" lacks "$out" "exempt.md"
mkdir -p docs/archive && seq 1 9 > docs/archive/old.md && git add -A
out=$("$B/sdlc-budget")
check "except skips matching files" lacks "$out" "docs/archive/old.md"
out=$(hook state-card.sh '{"source":"startup"}')
check "state card shows budget problems" has "$out" "progress/now.md: 20 lines"

# handoff check
block='STATUS: done
STEP: S4
ARTIFACTS: src/fog.ts
VERIFY: npm test -> pass, 12 tests
DECISIONS: none
OPEN: none
NEXT: reviewer, to review S4'
msg=$(printf 'Work done.\n%s\n' "$block" | jq -Rs .)
out=$(hook check-handoff.sh '{"agent_type":"builder","last_assistant_message":'"$msg"'}')
check "handoff check passes a complete block" empty "$out"
out=$(hook check-handoff.sh '{"agent_type":"sdlc-lean:builder","last_assistant_message":"All done."}')
check "handoff check blocks a missing block" has "$out" "Missing: STATUS STEP ARTIFACTS VERIFY DECISIONS OPEN NEXT"
msg=$(printf '%s\n' "$block" | grep -v '^NEXT' | sed 's/STATUS: done/STATUS: finished/' | jq -Rs .)
out=$(hook check-handoff.sh '{"agent_type":"reviewer","last_assistant_message":'"$msg"'}')
check "handoff check names a missing field" has "$out" "Missing: NEXT"
check "handoff check rejects a bad status" has "$out" "STATUS must be done, partial or blocked"
out=$(hook check-handoff.sh '{"agent_type":"Explore","last_assistant_message":"Found it."}')
check "handoff check ignores agents not listed" empty "$out"
out=$(hook check-handoff.sh '{"agent_type":"builder","stop_hook_active":true,"last_assistant_message":"x"}')
check "handoff check never loops" empty "$out"

# role-work guard (R-TEAM-003)
deny='"permissionDecision": "deny"'
write() { printf '{"tool_name":"%s","tool_input":{"file_path":"%s"}%s}' "$1" "$2" "${3:+,\"agent_type\":\"$3\"}"; }
run() { printf '{"tool_name":"Bash","tool_input":{"command":"%s"}%s}' "$1" "${2:+,\"agent_type\":\"$2\"}"; }
out=$(hook guard-role-work.sh "$(write Write "$P/src/fog.ts")")
check "role guard denies the main session writing code" has "$out" "$deny"
check "role guard names the rule" has "$out" "R-TEAM-003"
check "role guard names the next ready step" has "$out" "Next ready step: S2 · builder"
out=$(hook guard-role-work.sh "$(write Edit "$P/plan/steps/S5.md")")
check "role guard leaves step files to product" has "$out" "$deny"
out=$(hook guard-role-work.sh '{"tool_name":"NotebookEdit","tool_input":{"notebook_path":"'"$P"'/a.ipynb"}}')
check "role guard denies a notebook edit" has "$out" "$deny"
for f in progress/now.md progress/waiting.md plan/queue.json; do
  out=$(hook guard-role-work.sh "$(write Write "$P/$f")")
  check "role guard lets the main session write $f" empty "$out"
done
out=$(hook guard-role-work.sh "$(write Write /tmp/notes.md)")
check "role guard ignores files outside the project" empty "$out"
out=$(hook guard-role-work.sh "$(write Write "$P/src/fog.ts" sdlc-lean:builder)")
check "role guard lets a role agent write code" empty "$out"
for c in "git commit -m x" "git add -A && git commit -qm x" "git -C /tmp/r commit"; do
  out=$(hook guard-role-work.sh "$(run "$c")")
  check "role guard denies the main session: $c" has "$out" "$deny"
done
for c in "git status" "echo git commit" "git log --grep=commit"; do
  out=$(hook guard-role-work.sh "$(run "$c")")
  check "role guard allows the main session: $c" empty "$out"
done
out=$(hook guard-role-work.sh "$(run "git commit -m x" builder)")
check "role guard lets a role agent commit" empty "$out"
cp .claude/sdlc.json "$P/sdlc.bak"
jq 'del(.handoff_agents) | .main_session_writes = ["src/*"]' "$P/sdlc.bak" > .claude/sdlc.json
out=$(hook guard-role-work.sh "$(write Write "$P/lib/a.ts")")
check "role guard is off without handoff_agents" empty "$out"
jq '.main_session_writes = ["src/*"]' "$P/sdlc.bak" > .claude/sdlc.json
out=$(hook guard-role-work.sh "$(write Write "$P/src/fog.ts")")
check "main_session_writes widens what the main session may write" empty "$out"
out=$(hook guard-role-work.sh "$(write Write "$P/progress/now.md")")
check "main_session_writes replaces the default list" has "$out" "$deny"
mv "$P/sdlc.bak" .claude/sdlc.json

# queue check
queue_input='{"tool_input":{"file_path":"'"$P"'/plan/queue.json"}}'
out=$(hook check-queue.sh "$queue_input")
check "queue check passes a valid queue" empty "$out"
cp plan/queue.json "$P/queue.bak"
cat > plan/queue.json <<'JSON'
{ "next_id": 2, "steps": [
  { "id": "S1", "goal": "Word counter", "owner": "builder", "tier": "feature", "verify": "npm test" },
  { "id": "step-2", "title": "ok", "owner": "builder", "tier": "S", "status": "ready", "verify": "npm test" }
] }
JSON
out=$(hook check-queue.sh "$queue_input")
check "queue check blocks a bad queue" has "$out" '"decision": "block"'
check "queue check names a missing field" has "$out" "S1: missing title"
check "queue check names an unknown field" has "$out" "S1: unknown field goal"
check "queue check names a bad value" has "$out" 'S1: tier is \"feature\"; it must be one of S, M, L'
check "queue check names a bad id" has "$out" "step-2: id is"
printf '{ "next_id": 1, "steps": [' > plan/queue.json
out=$(hook check-queue.sh "$queue_input")
check "queue check reports broken JSON" has "$out" "could not be read"
out=$(hook check-queue.sh '{"tool_input":{"file_path":"'"$P"'/progress/now.md"}}')
check "queue check ignores other files" empty "$out"
mv "$P/queue.bak" plan/queue.json

# compaction snapshot
echo change >> progress/waiting.md
hook snapshot-state.sh '{"trigger":"auto"}'
snap=$(cat .claude/out/snapshot.md 2>/dev/null)
check "snapshot names the step in progress" has "$snap" "Step in progress: S4 Fog fades"
check "snapshot lists uncommitted changes" has "$snap" "progress/waiting.md"
out=$(hook state-card.sh '{"source":"compact"}')
check "state card shows the snapshot after compaction" has "$out" "Snapshot taken before compaction (auto"

if [ -n "$fails" ]; then
  echo "sdlc-core tests: $pass passed, $(printf '%s' "$fails" | grep -c FAIL) failed:$fails"
  exit 1
fi
echo "sdlc-core tests: $pass passed"
