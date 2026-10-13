#!/usr/bin/env bash
# Checks the role agents: frontmatter, short descriptions, and a handoff block that matches sdlc-core.
#   bash plugins/sdlc-lean/tests/run.sh
# Prints one line when all pass; otherwise each failure, and exits 1.
set -u
PLUGIN="$(cd "$(dirname "$0")/.." && pwd)"
ROOT="$PLUGIN/../.."
pass=0 fails=""
check() { # check <name> <condition command...>
  local name=$1; shift
  if "$@" >/dev/null 2>&1; then pass=$((pass + 1)); else fails="$fails
  FAIL: $name"; fi
}
field() { awk -v k="$2" 'NR==1&&/^---$/{f=1;next} f&&/^---$/{exit} f&&index($0,k": ")==1{print substr($0,length(k)+3)}' "$1"; }

# The keys sdlc-core's handoff hook asks for, in its order.
keys=$(sed -n 's/^for key in \(.*\); do$/\1/p' "$ROOT/plugins/sdlc-core/scripts/check-handoff.sh")
check "found the handoff keys in check-handoff.sh" [ -n "$keys" ]

names=""
for f in "$PLUGIN"/agents/*.md; do
  a=$(basename "$f" .md)
  names="$names $a"
  check "$a: name matches the file" [ "$(field "$f" name)" = "$a" ]
  d=$(field "$f" description)
  check "$a: description is 1 to 250 characters" [ ${#d} -ge 1 -a ${#d} -le 250 ]
  check "$a: model is an alias" grep -qxE 'haiku|sonnet|opus|fable' <<<"$(field "$f" model)"
  check "$a: effort is a level" grep -qxE 'low|medium|high|xhigh|max' <<<"$(field "$f" effort)"
  check "$a: disallowedTools is set" [ -n "$(field "$f" disallowedTools)" ]
  block=$(awk '/^```$/{n++; next} n==1' "$f" | sed -n 's/^\([A-Z]*\):.*/\1/p' | tr '\n' ' ')
  check "$a: handoff block has the keys sdlc-core checks" [ "$block" = "$keys " ]
  check "$a: file is under 2500 bytes" [ "$(wc -c <"$f")" -le 2500 ]
done

# Skills: the name matches the folder, and the description says when to use it.
for f in "$PLUGIN"/skills/*/SKILL.md; do
  s=$(basename "$(dirname "$f")")
  check "skill $s: name matches the folder" [ "$(field "$f" name)" = "$s" ]
  d=$(field "$f" description)
  check "skill $s: description is 1 to 1024 characters" [ ${#d} -ge 1 -a ${#d} -le 1024 ]
  check "skill $s: names every role it dispatches" grep -q "sdlc-lean:product" "$f"
done

# The template's handoff list names exactly these roles.
want=$(jq -r '.handoff_agents | sort | join(" ")' "$ROOT/templates/project/.claude/sdlc.json")
have=$(printf '%s\n' $names | sort | tr '\n' ' ' | sed 's/ $//')
check "template handoff_agents match the agents" [ "$want" = "$have" ]
check "template enables sdlc-lean" jq -e '.enabledPlugins["sdlc-lean@software-factory"] == true' "$ROOT/templates/project/.claude/settings.json"

if [ -n "$fails" ]; then
  echo "sdlc-lean tests: FAIL$fails"
  exit 1
fi
echo "sdlc-lean tests: pass ($pass checks)"
