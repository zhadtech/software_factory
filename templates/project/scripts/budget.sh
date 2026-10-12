#!/usr/bin/env bash
# Checks files against the size budgets in .claude/sdlc.json.
#   sdlc-budget [file ...]     paths relative to the project root; no files = every budgeted file
# Prints one line per file over a budget and exits 1. Prints nothing and exits 0 when all fit.
# Each budget: {"path": glob, "max_lines": n, "max_bytes": n, "max_line_chars": n,
#               "except": a glob of files the budget skips,
#               "unless": text that exempts the file when it appears in its first 15 lines,
#               "hint": what to do when over}. * in a glob matches across folders.
# The same file ships to projects as scripts/budget.sh; keep the two identical.
root=${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}
config="$root/.claude/sdlc.json"
[ -f "$config" ] || exit 0
cd "$root" || exit 2

# Read each budget field once, one line per budget, so the per-file loop runs no jq.
field() { jq -r --arg f "$1" '.budgets // [] | .[] | (.[$f] // "" | tostring | gsub("\n"; " "))' "$config"; }
patterns=() excepts=() unlesses=() hints=() max_lines=() max_bytes=() max_chars=()
while IFS= read -r v; do patterns+=("$v"); done < <(field path)
while IFS= read -r v; do excepts+=("$v"); done < <(field except)
while IFS= read -r v; do unlesses+=("$v"); done < <(field unless)
while IFS= read -r v; do hints+=("$v"); done < <(field hint)
while IFS= read -r v; do max_lines+=("$v"); done < <(field max_lines)
while IFS= read -r v; do max_bytes+=("$v"); done < <(field max_bytes)
while IFS= read -r v; do max_chars+=("$v"); done < <(field max_line_chars)
[ ${#patterns[@]} -gt 0 ] || exit 0

if [ $# -gt 0 ]; then files=$(printf '%s\n' "$@")
else files=$(git ls-files -co --exclude-standard 2>/dev/null); fi

status=0
while IFS= read -r file; do
  [ -f "$file" ] || continue
  for i in "${!patterns[@]}"; do
    # shellcheck disable=SC2053  # patterns are globs on purpose
    [[ $file == ${patterns[$i]} ]] || continue
    # shellcheck disable=SC2053
    [ -n "${excepts[$i]}" ] && [[ $file == ${excepts[$i]} ]] && continue
    [ -n "${unlesses[$i]}" ] && head -15 "$file" | grep -qF "${unlesses[$i]}" && continue
    problems=""
    max=${max_lines[$i]}
    if [ -n "$max" ]; then n=$(awk 'END { print NR }' "$file"); [ "$n" -gt "$max" ] && problems="$problems, $n lines (budget $max)"; fi
    max=${max_bytes[$i]}
    if [ -n "$max" ]; then n=$(wc -c <"$file" | tr -d ' '); [ "$n" -gt "$max" ] && problems="$problems, $n bytes (budget $max)"; fi
    max=${max_chars[$i]}
    if [ -n "$max" ]; then
      n=$(LC_ALL=en_US.UTF-8 awk -v m="$max" 'length($0) > m { c++ } END { print c + 0 }' "$file")
      [ "$n" -gt 0 ] && problems="$problems, $n line(s) longer than $max characters"
    fi
    if [ -n "$problems" ]; then
      echo "$file:${problems#,}${hints[$i]:+. ${hints[$i]}}"
      status=1
    fi
  done
done <<<"$files"
exit $status
