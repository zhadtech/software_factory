---
name: secure-code-review
description: Review a diff for correctness, security, tests and maintainability, and produce severity-ranked findings with a verdict. Use before merging, when reviewing a PR or branch, as a self-check before opening a PR, or when auditing security-relevant code.
---

# Secure Code Review

## Procedure

1. **Get the diff** (`git diff`, PR branch, or named paths) and read enough surrounding code to
   judge fit, not just correctness in isolation.
2. **Read the acceptance criteria and relevant ADRs first.** Clean code that does the wrong thing
   is still a reject.
3. Run the four passes below.
4. **Verify** — run the tests, linter and type checker yourself rather than trusting the description.
5. **Rank and report** with a verdict and the conditions that would change it.

## Pass 1 — Correctness

For each hunk, ask: *what input or state makes this wrong?*

- Boundaries: empty, null/None, zero, one, max, negative, unicode, very large
- Error paths: is every failure handled or deliberately propagated? Any swallowed exception?
- Concurrency: shared mutable state, check-then-act races, transaction boundaries, idempotency on retry
- Partial failure: what if the second of three calls fails? Is the system left consistent?
- Resource lifecycle: connections, files, locks, subscriptions — all released on every path?
- Off-by-one, inclusive/exclusive ranges, pagination edges, timezone and DST handling

## Pass 2 — Security

- **Authorisation on every new entry point** — and enforced at the data layer, not only the route.
- **Tenant isolation** — is the tenant/owner constraint part of the query, or assumed from the path?
- Injection: SQL/NoSQL (parameterised?), command, template, LDAP, path traversal, header injection
- Output encoding for the sink: HTML, attribute, JS, URL, SQL — context-correct?
- Secrets: none in code, config, logs, error messages, or test fixtures
- Sensitive data in logs, metrics labels, traces, URLs or analytics
- Deserialisation of untrusted input; file upload type/size/path handling
- SSRF: does user input reach a server-side fetch? Is the destination allow-listed?
- Crypto: standard library, not hand-rolled; correct mode; random from a CSPRNG; no fixed IV/salt
- Rate limiting and resource bounds on new public endpoints
- New dependencies: necessary, maintained, licence-compatible, no known criticals

## Pass 3 — Tests

- Does every acceptance criterion have a test?
- Would these tests **fail** if the behaviour regressed? (Mentally break the code and check.)
- Are negatives and boundaries covered, or only the happy path?
- Deterministic? Any sleeps, shared state, or order dependence introduced?
- Are assertions specific, or do they merely confirm that something happened?

## Pass 4 — Maintainability

- Naming that says what, not how; no abbreviations the codebase does not already use
- Duplication that will drift apart; abstraction invented for a single caller
- Function doing several things at different altitudes
- Dead code, commented-out code, TODOs without an issue reference
- Consistency with the nearest analogous code in this repo — not with generic style opinion
- Performance sanity: N+1 queries, unbounded result sets, sync I/O in a hot path, missing pagination

## Finding format

```markdown
**[Sev2 · security] Tenant isolation missing on the export endpoint**
`src/api/export.py:88`

`get_report(report_id)` looks up by primary key without constraining to the caller's tenant.

*Failure scenario:* a user authenticated to tenant B calls `GET /export/7f2a…` with a report ID
belonging to tenant A and receives the full report. IDs are UUIDs, but they appear in shared
links and in the audit log, so this is reachable in practice.

*Fix:* add the tenant constraint to the query itself (`.filter(tenant_id=ctx.tenant_id)`), and add
a test asserting 404 for a cross-tenant ID.
```

## Verdict

State one, with conditions:

- **Approve** — nothing blocking; list what you checked so the approval means something
- **Approve with comments** — non-blocking items named as non-blocking
- **Request changes** — list exactly which findings block, and what would flip the verdict

## Rules

- Do not modify the code you are reviewing. Report; the author fixes.
- Never approve without saying what you verified.
- Label opinions as opinions. Blocking findings need a concrete failure scenario.
- Author ≠ reviewer. If you wrote it, say so and route it elsewhere.
- Review the change, never the person.
