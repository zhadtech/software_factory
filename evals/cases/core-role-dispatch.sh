# Does the main session hand a plain request to product, as R-TEAM-003 says?
# The variant without sdlc-core still has the rule in AGENTS.md but no role-work guard.
# Fields are described in evals/cases/stacks-python-encoding.sh.
PLUGIN=sdlc-core
RULES="R-TEAM-003"
WITH="sdlc-core sdlc-lean"
WITHOUT="sdlc-lean"
MODEL=haiku
TURNS=16
PROMPT="Add a Python 3 script that counts the words in a file, with tests. Standard library only. I approve in advance the steps you write; do not stop to confirm them."
setup() { bash "$root/scripts/new-project.sh" . >/dev/null; }
# Judges the outcome: passes when the main session called the product role and none of its own
# writes outside progress/ and plan/queue.json went through. A write the guard refused does not count.
check() {
  jq -R -s '[split("\n")[] | fromjson?] as $e
    | [$e[] | select(.type? == "assistant" and .parent_tool_use_id == null) | .message.content[]? | select(.type == "tool_use")] as $calls
    | ([$e[] | select(.type? == "user") | .message.content[]? | select(.type? == "tool_result" and .is_error == true) | .tool_use_id]) as $refused
    | ($calls | any(.name == "Agent" and .input.subagent_type == "sdlc-lean:product")) as $product
    | ($calls | map(select((.name == "Write" or .name == "Edit")
        and ((.input.file_path // "") | test("/(progress/[^/]+|plan/queue\\.json)$") | not)
        and (.id as $i | $refused | index($i) | not))) | length) as $writes
    | $product and $writes == 0' "$TRANSCRIPT" | grep -qx true
}
