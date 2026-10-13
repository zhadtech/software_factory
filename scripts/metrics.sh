#!/usr/bin/env bash
# The factory's own measures: what a fresh project costs at boot, and how big the rule set is.
#   bash scripts/metrics.sh            one line per measure
#   bash scripts/metrics.sh --record   also add a row to metrics/factory.csv
# Boot is measured in a fresh project from the template, with sdlc-metrics, plus the lean roles'
# descriptions, which Claude Code lists in every session.
set -u
cd "$(dirname "$0")/.." || exit 2
d=$(mktemp -d) && trap 'rm -rf "$d"' EXIT
bash scripts/new-project.sh "$d/p" >/dev/null || exit 1
project_boot=$(cd "$d/p" && "$OLDPWD/plugins/sdlc-core/bin/sdlc-metrics" --csv | tail -1 | cut -d, -f11)
roles=0
for f in plugins/sdlc-lean/agents/*.md; do
  n=$(awk 'NR==1&&/^---$/{f=1;next} f&&/^---$/{exit} f&&/^description: /{print length($0)-13}' "$f")
  roles=$((roles + ${n:-0}))
done
boot=$((project_boot + roles))
read -r active trial proposed <<<"$(ruby -ryaml -rdate -e '
  r = YAML.safe_load_file("registry/rules.yaml", permitted_classes: [Date])
  puts %w[active trial proposed].map { |s| r.count { |x| x["status"] == s } }.join(" ")')"
template_rules=$(grep -c '^\*\*R-' templates/project/AGENTS.md)
stacks=$(jq '.stacks | length' plugins/sdlc-stacks/rules.json)
stack_rules=$(jq '.rules | length' plugins/sdlc-stacks/rules.json)
pool=$(grep -cE '^[0-9]+\. ' registry/pool.md)
intel=$(cat intel/inbox/*.md 2>/dev/null | grep -c '^## ')

if [ "${1:-}" = --record ]; then
  mkdir -p metrics
  [ -f metrics/factory.csv ] ||
    echo "date,boot_bytes,rules_active,rules_trial,rules_proposed,template_rules,stacks,stack_rules,pool_tips,intel_items" >metrics/factory.csv
  echo "$(date +%F),$boot,$active,$trial,$proposed,$template_rules,$stacks,$stack_rules,$pool,$intel" >>metrics/factory.csv
fi
echo "boot: $boot bytes before the first step in a fresh project ($project_boot from files and the state card, $roles from the lean roles' descriptions)"
echo "rules: $active active, $trial on trial, $proposed proposed; $template_rules in the template's AGENTS.md"
echo "stacks: $stacks, with $stack_rules rules that load near matching files"
echo "pool: $pool candidate tips; intel: $intel items found by the scout so far"
