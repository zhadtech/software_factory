#!/usr/bin/env bash
# Quiet verify: one line per stage on success; on failure, only what failed. Full logs in .verify/.
# Records the result in .verify/last-result, which the state card shows.
# Replace the example stages with this project's own.
set -u
cd "$(dirname "$0")/.." || exit 2
mkdir -p .verify

stage() {
  if ! scripts/quiet-run.sh "$@"; then
    echo "fail at $1 $(date '+%Y-%m-%d %H:%M')" >.verify/last-result
    exit 1
  fi
}

# Example stages for a Node project:
#   stage typecheck npm run --silent typecheck
#   stage test npm test --silent
stage budget scripts/budget.sh

echo "pass $(date '+%Y-%m-%d %H:%M')" >.verify/last-result
echo "verify: pass"
