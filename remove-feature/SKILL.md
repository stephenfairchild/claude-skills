---
name: remove-feature
description: Remove a feature, service, scraper or integration and everything it leaves orphaned (code, tables, secrets, images, jobs, docs). Use when the user says "remove", "delete", "get rid of", or "remove anything orphaned".
---

# Remove a feature and what it leaves behind

Deleting code is easy to undo with git. Deleting data, secrets and cloud resources is not. Treat the two differently.

## 1. Find everything that belongs to it

Search for the feature's name, routes, env vars, table names and image names across the whole repo, not just its own directory. Check each of:

- Code and tests, and imports or modules only it used.
- Deploy config: Helm values, Dockerfiles, Compose, CronJobs, CI or pipeline entries, Makefile targets.
- Config and docs: `README`, `CLAUDE.md`, skills, dashboards, diagrams.
- Secrets and env files, and the example files that list them.
- Database tables, columns, migrations and seed data.
- Dependencies in lockfiles that nothing else uses.
- Runtime state: running pods or containers, volumes, images, buckets, DNS records, webhooks.

## 2. Show the plan before deleting

Present the list in two groups:

- **Code and config in git**: safe to remove, reversible.
- **Data and live resources**: tables, volumes, secrets, buckets, DNS, running workloads. Say what each holds and whether a backup exists.

Ask before removing anything in the second group, and before each destructive step. A yes to the first group is not a yes to the second. Look at the target (row counts, size, last write) before dropping it.

## 3. Remove

Remove code and config first, then confirmed live resources. Keep the repo building: remove references from the other files that pointed to it. Do not leave commented-out code or "removed" notes behind.

## 4. Verify

Search again for the feature's names and confirm nothing remains. Run whatever render, lint or test commands the repo has (for example `helm template`) to show nothing broke. Report what was removed, what was kept on purpose and why, and any manual step left (a console deletion, a credential to revoke).
