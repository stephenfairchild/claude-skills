---
name: extract-test-rules
description: Scan every test in a service (unit, API, integration, e2e) and extract the business rules they encode, then write them as a numbered plain-text list to the user's cache directory. Use when asked to extract, document, or reverse-engineer business rules from tests, or when invoked as /extract-test-rules in any service repo.
---

# extract-test-rules

Reverse-engineer a service's business rules from its test suite and save them as a numbered `.txt` file, one rule per line.

## Input

Optional argument: path to the service root. Default to the current working directory (or the git root if inside a repo). Confirm the directory looks like a service (has source plus tests); if not, say so and stop.

## Output

- Directory: `~/.cache/extract-test-rules/<service-name>/` (`<service-name>` = basename of the service root; create the directory if needed).
- File: `business-rules-<YYYYMMDD-HHMMSS>.txt`. Also copy to `business-rules-latest.txt` in the same directory.
- Format: an ordered list, **exactly one rule per line**, no blank lines between rules, no wrapped lines, no sub-bullets:

```
1. An offer cannot be submitted after its auction has closed.
2. A refund is only issued when the order status is "delivered" and within 30 days.
```

- Optionally group by area using a plain header line like `## Offers` only if the user asks. Default is a single flat, continuously numbered list.
- After writing, print the absolute file path, the rule count, and the number of test files scanned. Do not dump the whole list into chat unless asked.

## Procedure

1. **Discover test files.** Use Glob/Grep (not a full read of every file up front). Cover all test types and common conventions across languages:
   - Names/dirs: `test/`, `tests/`, `__tests__/`, `spec/`, `e2e/`, `integration/`, `api/`, `it/`, `src/test/`
   - Patterns: `*_test.go`, `*.test.{ts,tsx,js,jsx}`, `*.spec.{ts,js}`, `test_*.py`, `*_test.py`, `*Test.java`, `*Tests.cs`, `*_spec.rb`, `*Test.kt`, `*.feature` (Gherkin), Postman/Newman collections, `*.http` files
   - Exclude: `node_modules`, `vendor`, `dist`, `build`, `.git`, generated mocks, snapshots/fixtures that are pure data (but read fixtures when a test depends on them to understand a rule).
2. **Partition and parallelize.** If there are more than ~25 test files, split them into groups by directory/type and spawn parallel `Explore` or `general-purpose` agents, each returning candidate rules as plain lines. Give each agent the extraction rules below verbatim. For small suites, do it inline.
3. **Extract rules.** For each test, read the name, setup, inputs, and assertions, and state the rule the test protects. Consult the source under test when the test alone is ambiguous (thresholds, enum values, status names).
4. **Merge and clean** (see rules below), then write the file.

## What counts as a business rule

Include behavior a product owner or domain expert would recognize:
- Validation and constraints (required fields, limits, formats that have domain meaning)
- State transitions and lifecycle (who/what can move from state A to B, and when)
- Calculations (fees, pricing, thresholds, rounding, date windows)
- Authorization and eligibility (which roles/users/conditions allow an action)
- Error and rejection conditions with domain meaning (what is refused and why)
- Side effects (events emitted, notifications sent, records created) that the domain requires
- Defaults, ordering, uniqueness, idempotency, and retry/timeout behavior when they are domain-relevant
- Edge cases and boundaries (exactly at the limit, zero, empty, duplicate)

Exclude pure technical/implementation checks: mock wiring, "function is called once", framework behavior, logging format, serialization plumbing, and tests of third-party libraries. Include an HTTP status or error code only when it expresses a business outcome (e.g., "returns 409 when a duplicate bid is placed").

## Writing the rules

- One sentence per rule, present tense, plain domain language, specific values included (e.g., "within 30 days", "at least 3 photos").
- State the condition and the outcome: "When X, the system Y" or "X cannot Y unless Z".
- Be precise, not generic. Prefer "A bid lower than the current high bid plus the minimum increment is rejected" over "Bids are validated".
- Do not invent rules the tests do not support. If a test is ambiguous, either read the source or skip it. If inferred with moderate confidence, append ` (inferred)`.
- Deduplicate: the same rule appearing in unit, API, and integration tests is listed once. Merge near-duplicates, keeping the most specific wording and values. If tests conflict on a value, list both and append ` (conflict: see <test file>)`.
- Order logically: group related rules adjacent to each other (by domain entity or flow), then number continuously from 1.
- Skipped/disabled/`xit`/`@Ignore`/`t.Skip` tests: omit by default; they may be stale.

## Safety (ACV data policy)

- Never copy secrets, API keys, tokens, passwords, certificates, SSNs, payment/bank data, or real customer/personal data found in test files or fixtures into the output. Describe the rule generically instead (e.g., "a valid API token is required").
- If a real-looking credential appears in a test, mention it to the user (without echoing the value) and suggest rotating it and reporting to security@acvauctions.com.
- Test source code is Class 3 (Confidential): the output file stays local in the cache directory. Do not upload, post, or send it anywhere unless the user explicitly asks.

## Final response

Keep it short:
- Output path (absolute)
- Counts: test files scanned (by type if known), rules written
- Any caveats: areas with no tests, skipped tests, conflicts, rules marked inferred
