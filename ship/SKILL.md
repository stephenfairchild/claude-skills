---
name: ship
description: Commit and push the current work, and deploy it if the repo has a deploy step. Use when the user says "commit and push", "commit and deploy", "ship it", or "deploy".
---

# Commit, push, and deploy

## 1. Look before committing

Run `git status` and `git diff` (staged and unstaged). Check the last few commits with `git log --oneline -8` and match their message style.

- Stage files by name, not `git add -A`. Leave out `.DS_Store`, build output, `.env` files and anything that looks like a credential or key. If a changed file contains a secret, stop and tell the user. Do not print the secret.
- If the diff mixes unrelated changes, say so and offer to make separate commits.
- If you are on the default branch and the repo uses PRs, create a branch first.

## 2. Commit and push

Write a message that says why the change was made, not only what changed. Do not skip hooks (`--no-verify`). If a hook fails, fix the cause and make a new commit. Push to the tracking branch; never force-push without being asked.

## 3. Deploy (only if asked, or the user said "deploy")

Find the repo's deploy command in its `CLAUDE.md`, `README`, `Makefile` or CI config. Use that, not a guess. If there is none, say so and stop.

After deploying, verify it: check that the rollout or pipeline finished and look at recent logs or health for errors. Report plainly what is running now. If it failed, show the error and do not retry blindly.

## 4. Report

Give the commit hash, the branch, what was deployed, and anything left uncommitted and why.
