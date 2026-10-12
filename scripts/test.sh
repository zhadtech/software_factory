#!/usr/bin/env bash
# Every factory check in one run. Prints one line when all pass; otherwise each failure, exit 1.
#   bash scripts/test.sh
set -u
cd "$(dirname "$0")/.." || exit 2
fails="" ran=0 skipped=""
run() { # run <name> <command...>
  local name=$1 out
  shift
  ran=$((ran + 1))
  out=$("$@" 2>&1) || fails="$fails
--- $name ---
$(printf '%s\n' "$out" | tail -20)"
}

rule_files=(seeds/agi-standards/AGENTS.md)
[ -f ../fog_of_war/AGENTS.md ] && rule_files+=(../fog_of_war/AGENTS.md)
run "registry" ruby scripts/check-registry.rb "${rule_files[@]}"
run "AGENTS.md template is generated from the registry" ruby scripts/build-agents-md.rb --check
run "sdlc-core hooks" bash plugins/sdlc-core/tests/run.sh
run "template budget.sh matches sdlc-budget" cmp plugins/sdlc-core/bin/sdlc-budget templates/project/scripts/budget.sh

template_smoke() {
  local d
  d=$(mktemp -d) || return 1
  cp -R templates/project/. "$d/"
  (
    cd "$d" && git init -q -b main . && git add -A &&
      out=$(scripts/verify.sh) && [ "$out" = "budget: pass (0s)
verify: pass" ] && grep -q '^pass ' .verify/last-result &&
      jq -e '.steps == []' plan/queue.json >/dev/null &&
      { plugins_bin=$OLDPWD/plugins/sdlc-core/bin; "$plugins_bin/next-step" >/dev/null; [ $? -eq 1 ]; }
  ) || { echo "template verify or queue check failed in $d"; return 1; }
  rm -rf "$d"
}
run "a fresh project from the template passes its own verify" template_smoke

claude_bin=${CLAUDE_CODE_EXECPATH:-$(command -v claude)}
if [ -n "$claude_bin" ] && [ -x "$claude_bin" ]; then
  run "marketplace manifest" "$claude_bin" plugin validate .
  for p in plugins/*/; do run "plugin manifest ${p%/}" "$claude_bin" plugin validate "${p%/}"; done
else
  skipped="$skipped claude-plugin-validate"
fi

# A plugin change reaches projects only when its version changes.
base=$(git rev-parse --verify -q origin/main || git rev-parse --verify -q main)
if [ -n "$base" ]; then
  for p in plugins/*/; do
    p=${p%/}
    git diff --quiet "$base" -- "$p" && continue
    old=$(git show "$base:$p/.claude-plugin/plugin.json" 2>/dev/null | jq -r '.version // empty')
    new=$(jq -r '.version // empty' "$p/.claude-plugin/plugin.json")
    ran=$((ran + 1))
    [ -n "$old" ] && [ "$old" = "$new" ] && fails="$fails
--- $p changed since main but its version is still $new; bump it in $p/.claude-plugin/plugin.json ---"
  done
else
  skipped="$skipped version-bump(no main branch yet)"
fi

if [ -n "$fails" ]; then
  echo "factory checks: FAIL$fails"
  exit 1
fi
echo "factory checks: pass ($ran checks${skipped:+; skipped:$skipped})"
