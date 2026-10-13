# Does the main session hand a plain request to product, as R-TEAM-003 says?
# The variant without sdlc-core still has the rule in AGENTS.md but no role-work guard.
# Fields are described in evals/cases/stacks-python-encoding.sh.
PLUGIN=sdlc-core
RULES="R-TEAM-003"
WITH="sdlc-core sdlc-lean"
WITHOUT="sdlc-lean"
MODEL=haiku
TURNS=8
PROMPT="Add a Python 3 script that counts the words in a file, with tests. Standard library only. I approve in advance the steps you write; do not stop to confirm them."
setup() { bash "$root/scripts/new-project.sh" . >/dev/null; }
# Passes when the main session calls the product role before it writes anything outside
# progress/ and plan/queue.json.
check() {
  jq -R -s -r '[split("\n")[] | fromjson? | select(.type? == "assistant" and .parent_tool_use_id == null)
      | .message.content[]? | select(.type == "tool_use")
      | if .name == "Agent" then "agent:" + (.input.subagent_type // "")
        elif (.name == "Write" or .name == "Edit") then "write:" + (.input.file_path // "") else empty end]
    | map(select(test("^agent:") or (test("/(progress/[^/]+|plan/queue\\.json)$") | not)))
    | first // "none"' "$TRANSCRIPT" | grep -qx 'agent:sdlc-lean:product'
}
