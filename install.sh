#!/usr/bin/env bash
# Install the SDLC agent team into a target project.
#   install.sh /path/to/project          copy (project owns its copy)
#   install.sh --link /path/to/project   symlink (project tracks this source)
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODE="copy"
if [[ "${1:-}" == "--link" ]]; then MODE="link"; shift; fi

TARGET="${1:-}"
if [[ -z "$TARGET" ]]; then
  echo "usage: $(basename "$0") [--link] /path/to/project" >&2; exit 1
fi
if [[ ! -d "$TARGET" ]]; then
  echo "error: target directory does not exist: $TARGET" >&2; exit 1
fi

TARGET="$(cd "$TARGET" && pwd)"
if [[ "$TARGET" == "$SRC" ]]; then
  echo "error: target is the source package itself" >&2; exit 1
fi

mkdir -p "$TARGET/.claude"

for kind in agents skills handbook; do
  dest="$TARGET/.claude/$kind"
  if [[ -e "$dest" && ! -L "$dest" ]]; then
    backup="$dest.backup.$(date +%Y%m%d%H%M%S)"
    echo "existing $dest -> $backup"
    mv "$dest" "$backup"
  elif [[ -L "$dest" ]]; then
    rm "$dest"
  fi

  if [[ "$MODE" == "link" ]]; then
    ln -s "$SRC/.claude/$kind" "$dest"
    echo "linked  $dest -> $SRC/.claude/$kind"
  else
    cp -R "$SRC/.claude/$kind" "$dest"
    echo "copied  $dest"
  fi
done

mkdir -p "$TARGET/docs/sdlc"
echo
echo "Installed $(ls "$SRC/.claude/agents" | wc -l | tr -d ' ') agents and $(ls "$SRC/.claude/skills" | wc -l | tr -d ' ') skills into $TARGET"
echo "Artifacts will be written under $TARGET/docs/sdlc/ — see .claude/handbook/ARTIFACTS.md"
