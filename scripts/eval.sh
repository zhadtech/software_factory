#!/usr/bin/env bash
# Runs eval cases headless, with and without the plugin under test, and records each run's
# pass and cost in evals/ledger.csv. Never spends past evals/budget.json for the month.
#   bash scripts/eval.sh --dry-run [case ...]   list what would run and the budget left; spend nothing
#   bash scripts/eval.sh --changed              the cases for plugins changed since main (CHARTER.md)
#   bash scripts/eval.sh <case> ...             named cases, such as stacks-python-encoding
#   --runs <n>                                   runs per variant, instead of the budget file's number
# Each run's session log is kept in $TMPDIR/sdlc-evals/<date>/, outside the repo, to read after.
# A case is evals/cases/<name>.sh; see the comment at the top of any case for its fields.
set -u
cd "$(dirname "$0")/.." || exit 2
root=$PWD
dry="" changed="" names="" runs_arg=""
while [ $# -gt 0 ]; do
  case $1 in --dry-run) dry=1 ;; --changed) changed=1 ;; --runs) runs_arg=${2:-}; shift ;; *) names="$names $1" ;; esac
  shift
done

monthly=$(jq -r .monthly_usd evals/budget.json) runs=$(jq -r .runs_per_case evals/budget.json)
per_run=$(jq -r .max_usd_per_run evals/budget.json)
[ -z "$runs_arg" ] || runs=$runs_arg
logs="${TMPDIR:-/tmp}/sdlc-evals/$(date +%F)" && mkdir -p "$logs"
[ -f evals/ledger.csv ] || echo "date,case,variant,run,pass,cost_usd" >evals/ledger.csv
month=$(date +%Y-%m)
spent=$(awk -F, -v m="$month" 'NR > 1 && index($1, m) == 1 { s += $6 } END { printf "%.2f", s + 0 }' evals/ledger.csv)

cases=""
if [ -n "$changed" ]; then
  base=$(git rev-parse --verify -q origin/main || git rev-parse --verify -q main) || { echo "no main branch to compare with" >&2; exit 2; }
  for p in $(git diff --name-only "$base" -- plugins/ | cut -d/ -f2 | sort -u); do
    cases="$cases $(grep -l "^PLUGIN=$p\$" evals/cases/*.sh 2>/dev/null | xargs -n1 basename 2>/dev/null | sed 's/\.sh$//')"
  done
elif [ -n "$names" ]; then
  cases=$names
else
  cases=$(ls evals/cases/*.sh | xargs -n1 basename | sed 's/\.sh$//')
fi
cases=$(printf '%s\n' $cases | sort -u)
[ -n "$cases" ] || { echo "eval: no cases to run"; exit 0; }
for c in $cases; do [ -f "evals/cases/$c.sh" ] || { echo "eval: no case named $c" >&2; exit 2; }; done

n=$(printf '%s\n' $cases | wc -l | tr -d ' ')
most=$(awk -v n="$n" -v r="$runs" -v p="$per_run" 'BEGIN { printf "%.2f", n * 2 * r * p }')
echo "eval: $n case(s), $runs runs each with and without the plugin; at most \$$most"
echo "eval: \$$spent of \$$monthly spent in $month"
echo "eval: session logs in $logs"
if [ -n "$dry" ]; then printf '  %s\n' $cases; exit 0; fi

claude_bin=${CLAUDE_CODE_EXECPATH:-$(command -v claude)}
[ -x "$claude_bin" ] || { echo "eval: claude is not installed" >&2; exit 2; }
summary=""
for c in $cases; do
  for variant in with without; do
    passes=0 cost_case=0 done_runs=0
    for i in $(seq 1 "$runs"); do
      if awk -v s="$spent" -v p="$per_run" -v m="$monthly" 'BEGIN { exit !(s + p > m) }'; then
        echo "eval: stopping; another run could pass the \$$monthly ceiling for $month (\$$spent spent)"
        break 3
      fi
      fixture=$(mktemp -d) log="$logs/$c-$variant-$i-$(date +%H%M%S).jsonl"
      result=$(
        cd "$fixture" || exit 2
        # shellcheck source=/dev/null
        . "$root/evals/cases/$c.sh"
        setup >/dev/null 2>&1
        plugins=$([ "$variant" = with ] && echo "$WITH" || echo "$WITHOUT")
        args=""
        for p in $plugins; do args="$args --plugin-dir $root/plugins/$p"; done
        # shellcheck disable=SC2086  # args is a list of flags
        "$claude_bin" -p "$PROMPT" --model "$MODEL" --max-turns "$TURNS" --max-budget-usd "$per_run" $args \
          --permission-mode acceptEdits --output-format stream-json --verbose \
          --allowedTools "Bash(git *)" "Bash(python3 *)" "Bash(rg *)" "Bash(jq *)" "Bash(ls *)" "Bash(wc *)" \
          >"$log" 2>/dev/null </dev/null
        cost=$(jq -R -s '[split("\n")[] | fromjson? | select(.type? == "result") | .total_cost_usd] | last // 0' "$log")
        if TRANSCRIPT=$log check >/dev/null 2>&1; then echo "1 $cost"; else echo "0 $cost"; fi
      )
      read -r pass cost <<<"$result"
      echo "$(date +%F),$c,$variant,$i,$pass,$cost" >>evals/ledger.csv
      spent=$(awk -v s="$spent" -v c="$cost" 'BEGIN { printf "%.2f", s + c }')
      passes=$((passes + pass)) done_runs=$((done_runs + 1))
      cost_case=$(awk -v a="$cost_case" -v c="$cost" 'BEGIN { printf "%.2f", a + c }')
      rm -rf "$fixture"
    done
    summary="$summary
$c, $variant the plugin: $passes of $done_runs passed (\$$cost_case)"
  done
done
printf '%s\n' "$summary" | sed '/^$/d'
echo "eval: \$$spent of \$$monthly spent in $month"
