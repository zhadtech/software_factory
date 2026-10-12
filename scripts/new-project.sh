#!/usr/bin/env bash
# Starts a project from the template: copies templates/project into a new or empty folder,
# makes it a git repo on main, and commits the starting files.
#   bash scripts/new-project.sh <folder>
set -eu
[ $# -eq 1 ] || { echo "usage: bash scripts/new-project.sh <folder>" >&2; exit 2; }
factory="$(cd "$(dirname "$0")/.." && pwd)"
dest=$1
if [ -e "$dest" ] && [ -n "$(ls -A "$dest")" ]; then
  echo "$dest is not empty; pick a new folder" >&2
  exit 1
fi
mkdir -p "$dest"
cp -R "$factory/templates/project/." "$dest/"
git -C "$dest" init -q -b main
git -C "$dest" add -A
git -C "$dest" commit -q -m "Start from the factory template"
echo "Made $dest. Start Claude Code there:"
echo "  cd $dest && claude"
