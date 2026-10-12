---
name: phase-gate-review
description: Run a formal SDLC phase gate — test exit criteria against evidence, record the verdict, approvers and any waiver. Use at G0–G6, before a release decision, or when someone asks whether work can move to the next phase.
---

# Phase Gate Review

A gate is a **recorded decision**, not a meeting. Its output is a file an auditor can read a year
later and understand exactly what was known, who decided, and on what evidence.

## Procedure

1. **Name the gate** and load its exit criteria from [WORKFLOW.md](../../handbook/WORKFLOW.md).
2. **Test each criterion independently.** For each: `met` / `not met` / `unverified`, with the
   artifact path that proves it. Open the artifact. A criterion backed by an assertion rather than
   a file is `unverified`.
3. **Collect role verdicts** from the accountable and consulted roles for that phase (see RACI).
4. **List open items** — defects by severity, open findings, open risks, expired waivers.
5. **Decide:** open · open with waiver · hold.
6. **Record** to `docs/sdlc/08-delivery/gate-reviews/GATE-<phase>-<date>.md`.
7. **Publish** the decision and the resulting work sequence.

## Gate record template

```markdown
---
gate: G4-Verify
date: 2026-09-15
chair: project-manager
decision: open-with-waiver
commit: 9f3c1ab   version: 2.14.0
---

## Exit criteria

| # | Criterion | Verdict | Evidence |
|---|-----------|---------|----------|
| 1 | All high-risk test cases executed | met | 05-quality/reports/exec-2026-09-14.md (142/142) |
| 2 | Requirement coverage complete | met | traceability.md — 0 gaps, 2 accepted-untested (approved by PM) |
| 3 | No open Sev1/Sev2 defects | **not met** | QA-0412 (Sev3), SEC-0021 (Sev2, open) |
| 4 | NFR budgets validated | met | 07-operations/performance/results-2026-09-13.md |
| 5 | Security review complete | met | 06-security/review-reports/2026-09-14.md |
| 6 | Accessibility AA conformance | unverified | report covers 34/38 criteria; 4 not exercised |

## Role verdicts
- qa-lead (A): conditional — criterion 6 incomplete
- security-officer (veto holder): **objects** to closing criterion 3 — SEC-0021 (erasure not
  implemented, GDPR Art.17) is Sev2 and unmitigated
- solution-architect: no objection
- devops-engineer: ready pending decision

## Decision: open with waiver

**Waiver W-0004** — SEC-0021 erasure job not implemented.
- Accepted by: <named human sponsor>, 2026-09-15
- Compensating control: manual erasure runbook (07-operations/runbooks/manual-erasure.md),
  executed by the data-engineer within 72 h of a request, logged as evidence
- Residual risk: manual process is unmonitored and depends on one role's availability; an
  Art.17 request during an outage or absence could breach the statutory deadline
- **Expires: 2026-10-15** — reopens as a Sev2 finding on expiry, blocking the next release

**Criterion 6** carried to G5 as a condition: complete the remaining 4 a11y criteria before release.

## Actions
| # | Action | Owner | Due |
|---|--------|-------|-----|
| 1 | Implement erasure job (SEC-0021) | data-engineer | 2026-10-08 |
| 2 | Exercise remaining a11y criteria | ux-designer | 2026-09-17 |
| 3 | Re-verify W-0004 before expiry | security-officer | 2026-10-14 |
```

## Rules

- **One criterion, one verdict, one evidence path.** No bundling.
- `unverified` is a legitimate verdict and is often the honest one. It is never the same as `met`.
- A criterion backed only by a role's assurance is not met. Open the artifact.
- **A waiver is not a pass.** It requires a named human approver, a compensating control, a written
  residual risk, and an expiry date. An expired waiver reopens as a finding automatically.
- The Security Officer's objection on a Sev1/Sev2 cannot be overruled by the chair — only by a named
  human sponsor accepting the risk in writing, and that acceptance is itself recorded here.
- Gates are dated and tied to a commit SHA and artifact versions. A gate record without them proves
  nothing about *what* was approved.
- Never backdate a gate record, and never edit a closed one — supersede it with a new record.
