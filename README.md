# claude-skills

A collection of reusable [Claude Code](https://claude.com/claude-code) skills. Each skill is a folder containing a `SKILL.md`.

## Skills

| Skill | Description |
| --- | --- |
| [`extract-test-rules`](extract-test-rules/SKILL.md) | Scans a service's tests (unit, API, integration, e2e) and extracts the business rules they encode into a numbered `.txt` file in `~/.cache/extract-test-rules/`. |

## Install

```sh
curl -fsSL https://raw.githubusercontent.com/stephenfairchild/claude-skills/main/install.sh | bash
```

This clones the repo to `~/.claude/claude-skills` and symlinks every skill into `~/.claude/skills`. Requires `git`. Restart Claude Code afterwards.

Re-run the same command any time to update.

## Usage

Invoke a skill by name:

```
/extract-test-rules
```

Claude can also pick a skill automatically when your request matches its description.
