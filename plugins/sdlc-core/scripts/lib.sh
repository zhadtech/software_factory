# Shared by every sdlc-core hook. Source it first.
# Reads the hook input once, finds the project, and exits quietly (a no-op hook)
# when the project has no .claude/sdlc.json. Works with the bash 3.2 that macOS ships.

command -v jq >/dev/null 2>&1 || { echo "sdlc-core: jq is not installed; hooks are off" >&2; exit 1; }

SDLC_INPUT=$(cat)
SDLC_DIR=${CLAUDE_PROJECT_DIR:-$(printf '%s' "$SDLC_INPUT" | jq -r '.cwd // empty')}
SDLC_CONFIG="$SDLC_DIR/.claude/sdlc.json"
SDLC_BIN="$(cd "$(dirname "${BASH_SOURCE[0]}")/../bin" && pwd)"
[ -n "$SDLC_DIR" ] && [ -f "$SDLC_CONFIG" ] || exit 0

# input '<jq filter>'  — a field of the hook input, raw.
input() { printf '%s' "$SDLC_INPUT" | jq -r "$1"; }
# config '<jq filter>' — a field of .claude/sdlc.json, raw.
config() { jq -r "$1" "$SDLC_CONFIG"; }
# relpath <absolute path> — the path relative to the project root.
relpath() { case "$1" in "$SDLC_DIR"/*) printf '%s' "${1#"$SDLC_DIR"/}" ;; *) printf '%s' "$1" ;; esac; }
