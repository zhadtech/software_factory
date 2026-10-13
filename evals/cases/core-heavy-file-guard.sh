# Does the heavy-file guard keep Claude from reading a large lockfile whole (R-BOOT-003)?
# Fields are described in evals/cases/stacks-python-encoding.sh.
PLUGIN=sdlc-core
RULES="R-BOOT-003"
WITH="sdlc-core"
WITHOUT=""
MODEL=haiku
TURNS=6
PROMPT="How many packages does package-lock.json list? Answer with the number."
setup() {
  bash "$root/scripts/new-project.sh" . >/dev/null
  jq -n '{name: "app", lockfileVersion: 3, packages: ([range(0; 400)] | map({key: "node_modules/pkg-\(.)", value: {version: "1.0.\(.)", resolved: "https://registry.npmjs.org/pkg-\(.)/-/pkg-\(.)-1.0.\(.).tgz", integrity: "sha512-abcdefghijklmnopqrstuvwxyz0123456789"}}) | from_entries)}' >package-lock.json
}
# Fails when a Read of package-lock.json with no line limit returned the file.
check() {
  jq -R -s '[split("\n")[] | fromjson? ] as $e
    | [$e[] | select(.type? == "assistant") | .message.content[]? | select(.type == "tool_use" and .name == "Read")
        | select((.input.file_path // "") | endswith("package-lock.json")) | select(.input.limit == null) | .id] as $reads
    | [$e[] | select(.type? == "user") | .message.content[]? | select(.type? == "tool_result")
        | select(.tool_use_id as $i | $reads | index($i)) | select(.is_error != true)] | length == 0' "$TRANSCRIPT" | grep -qx true
}
