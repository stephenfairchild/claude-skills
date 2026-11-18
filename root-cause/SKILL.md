---
name: root-cause
description: Investigate why something is failing and confirm the root cause with evidence before proposing any fix. Use when the user says "root cause", "why is this failing", "figure out why", or asks to talk about the cause and not the solution.
---

# Find the root cause, not a fix

The goal is a confirmed cause. Do not change code, config or infrastructure while investigating, and do not propose fixes until the user agrees the cause is right.

## 1. State the symptom

Write down what is observed, where and since when, in a sentence or two. Ask only if you cannot find it from the code, logs or the conversation.

## 2. Form hypotheses

List the plausible causes, most likely first. For each, name the one observation that would prove or rule it out.

## 3. Gather evidence

Test the hypotheses with read-only means: logs, metrics, recent deploys and `git log` for the area, config as it is actually running, a query against the data. When reading is not enough, reproduce the problem with a throwaway script, test or small UI (Playwright is fine) kept in the scratchpad directory, not in the repo.

- Separate what you observed from what you infer.
- A hypothesis is confirmed only when you can show the failure happen, or show the evidence that only that cause explains. "Looks like" is not confirmed.
- Change one variable at a time. Undo any temporary change you made to test.
- Follow the cause down: ask "why" until it is something that can be fixed, not a symptom of another failure.

## 4. Report

- **Root cause**: one or two sentences.
- **Evidence**: the specific logs, outputs or reproduction that prove it.
- **Ruled out**: what you checked that was not it.
- **Confidence**: confirmed, or what is still uncertain and how to settle it.

Then stop and ask whether to move on to fixes. Offer options only after that.
