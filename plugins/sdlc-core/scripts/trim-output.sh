#!/usr/bin/env bash
# PostToolUse on Bash: when stdout or stderr runs past trim_lines (default 120), saves the
# whole output to .claude/out/ and shows Claude the head, the error-like lines, the tail and
# the file path instead. Put SDLC_FULL_OUTPUT=1 in front of a command to keep its full output.
. "$(dirname "$0")/lib.sh"
case "$(input '.tool_input.command // ""')" in *SDLC_FULL_OUTPUT=1*) exit 0 ;; esac
max=$(config '.trim_lines // 120')
out=$(input '.tool_response.stdout // ""')
err=$(input '.tool_response.stderr // ""')
lines() { [ -z "$1" ] && echo 0 || printf '%s\n' "$1" | wc -l | tr -d ' '; }
n_out=$(lines "$out")
n_err=$(lines "$err")
[ "$n_out" -le "$max" ] && [ "$n_err" -le "$max" ] && exit 0

dir="$SDLC_DIR/.claude/out"
mkdir -p "$dir"
log="$dir/bash-$(date +%Y%m%d-%H%M%S)-$$.log"
{
  echo "\$ $(input '.tool_input.command // ""')"
  echo "--- stdout ($n_out lines) ---"; printf '%s\n' "$out"
  echo "--- stderr ($n_err lines) ---"; printf '%s\n' "$err"
} > "$log"
rel=$(relpath "$log")

# shorten <text> <line count> — head, error-like lines, tail, and where the rest is.
shorten() {
  [ "$2" -le "$max" ] && { printf '%s' "$1"; return; }
  printf '%s\n' "$1" | head -30
  echo "--- error-like lines ---"
  printf '%s\n' "$1" | grep -nE 'FAIL|Error|error:|ERR!|not ok|✖|panic|Traceback|Exception|fatal:' | head -30
  echo "--- last lines ---"
  printf '%s\n' "$1" | tail -20
  echo "[$2 lines in total; full output saved to $rel]"
}
short_out=$(shorten "$out" "$n_out")
short_err=$(shorten "$err" "$n_err")

printf '%s' "$SDLC_INPUT" | jq --arg o "$short_out" --arg e "$short_err" \
  '{hookSpecificOutput: {hookEventName: "PostToolUse", updatedToolOutput: (.tool_response + {stdout: $o, stderr: $e})}}'
