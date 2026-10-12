#!/usr/bin/env bash
# Runs one verify stage quietly. The full output goes to .verify/<name>.log.
# On success: one line. On failure: the error-like lines, the last lines and the log path.
#   scripts/quiet-run.sh <name> <command> [args ...]
set -u
name=$1
shift
mkdir -p .verify
log=".verify/$name.log"
start=$(date +%s)
"$@" >"$log" 2>&1
status=$?
secs=$(($(date +%s) - start))
if [ "$status" -eq 0 ]; then
  echo "$name: pass (${secs}s)"
  exit 0
fi
echo "$name: FAIL (exit $status, ${secs}s)"
grep -nE 'FAIL|Error|error:|ERR!|not ok|✖|panic|Traceback|Exception|failed' "$log" | head -40
echo "--- last lines ---"
tail -15 "$log"
echo "full log: $log"
exit "$status"
