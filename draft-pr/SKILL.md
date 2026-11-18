---
name: draft-pr
description: Open a draft pull request for the current work with a clear description. Use when the user says "draft pr", "open a pr", or "make a pr".
---

# Open a draft PR

Never mark the PR ready for review and never merge. Draft only.

## 1. Prepare the branch

- Run `git status`, `git branch --show-current` and `git log origin/HEAD..HEAD --oneline` (or against the default branch) to see what the PR will contain.
- If on the default branch, create a descriptively named branch first.
- Commit uncommitted work that belongs in the PR (stage by name, skip secrets and `.DS_Store`). Match the repo's commit style. Ask if it is unclear which changes belong.
- Push with `git push -u origin <branch>`.

## 2. Write the description

Read the full diff against the base branch, not just the last commit. Use the repo's `.github/pull_request_template.md` if there is one; otherwise:

- **Why**: the problem or goal in one or two sentences.
- **What changed**: the main changes grouped by area, not file by file.
- **How it was tested**: what was actually run. Do not claim tests that were not run.
- **Notes for the reviewer**: risks, migrations, config or secrets to add, follow-ups.

## 3. Create it

`gh pr create --draft --title "<short, imperative title>" --body "<body>"`

Add reviewers or labels only if the user named them. End the body with the attribution line the session instructions ask for, if any.

## 4. Report

Give the PR URL and a two-line summary. Mention anything the reviewer must do before it can merge (new Vault paths, env vars, a schema PR in another repo).
