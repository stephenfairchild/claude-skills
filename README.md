# claude-skills

A collection of reusable [Claude Code](https://claude.com/claude-code) skills. Each skill is a folder containing a `SKILL.md`.

## Skills

| Skill | Description |
| --- | --- |
| [`extract-test-rules`](extract-test-rules/SKILL.md) | Scans a service's tests (unit, API, integration, e2e) and extracts the business rules they encode into a numbered `.txt` file in `~/.cache/extract-test-rules/`. |

## Install

Clone the repo somewhere permanent:

```sh
git clone https://github.com/stephenfairchild/claude-skills ~/Code/claude-skills
```

### Personal install (available in every project)

Symlink the skill into `~/.claude/skills`:

```sh
mkdir -p ~/.claude/skills
ln -s ~/Code/claude-skills/extract-test-rules ~/.claude/skills/extract-test-rules
```

Install every skill in the repo at once:

```sh
mkdir -p ~/.claude/skills
for dir in ~/Code/claude-skills/*/; do
  ln -sfn "${dir%/}" ~/.claude/skills/"$(basename "$dir")"
done
```

Because these are symlinks, `git pull` in the repo updates your installed skills.

### Project install (shared with a single repo)

Copy a skill into the project's `.claude/skills` directory and commit it:

```sh
mkdir -p .claude/skills
cp -R ~/Code/claude-skills/extract-test-rules .claude/skills/
```

### Copy instead of symlink

If you prefer not to symlink, copy the folder instead:

```sh
cp -R ~/Code/claude-skills/extract-test-rules ~/.claude/skills/
```

You'll need to re-copy to pick up updates.

## Usage

Start (or restart) Claude Code, then invoke a skill by name:

```
/extract-test-rules
```

Claude can also pick a skill automatically when your request matches its description.

## Update

```sh
cd ~/Code/claude-skills && git pull
```

## Adding a skill

Create a new folder with a `SKILL.md` that has `name` and `description` frontmatter:

```
my-skill/
  SKILL.md
```

```markdown
---
name: my-skill
description: What the skill does and when Claude should use it.
---

Instructions for Claude go here.
```
