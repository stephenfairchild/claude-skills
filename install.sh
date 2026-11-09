#!/usr/bin/env bash
# Installs (or updates) all skills from stephenfairchild/claude-skills
# into ~/.claude/skills by symlinking each skill folder.
set -euo pipefail

REPO_URL="${CLAUDE_SKILLS_REPO:-https://github.com/stephenfairchild/claude-skills}"
CLONE_DIR="${CLAUDE_SKILLS_DIR:-$HOME/.claude/claude-skills}"
SKILLS_DIR="$HOME/.claude/skills"

command -v git >/dev/null 2>&1 || { echo "error: git is required" >&2; exit 1; }

mkdir -p "$SKILLS_DIR"

if [ -d "$CLONE_DIR/.git" ]; then
  echo "Updating $CLONE_DIR"
  git -C "$CLONE_DIR" pull -q --ff-only
else
  echo "Cloning $REPO_URL to $CLONE_DIR"
  git clone -q "$REPO_URL" "$CLONE_DIR"
fi

for dir in "$CLONE_DIR"/*/; do
  [ -f "${dir}SKILL.md" ] || continue
  name="$(basename "$dir")"
  target="$SKILLS_DIR/$name"
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    echo "Skipping $name: $target exists and is not a symlink" >&2
    continue
  fi
  ln -sfn "${dir%/}" "$target"
  echo "Installed $name"
done

echo "Done. Restart Claude Code to pick up new skills."
