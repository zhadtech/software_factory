---
name: sprint-and-raid-management
description: Plan iterations, forecast with real throughput, and maintain the RAID log (risks, assumptions, issues, dependencies) and status reporting. Use when planning a sprint, tracking progress, escalating a risk or blocker, or reporting status to a sponsor.
---

# Sprint Planning, RAID & Status

## Iteration planning

1. **Confirm the goal** — one sentence stating the outcome, not a list of tickets. If you cannot
   write it in one sentence, the iteration lacks focus.
2. **Check readiness (DoR)** — a story enters only if: acceptance criteria written, dependencies
   identified, design decided or explicitly deferred, sized by the doing role, no blocking open question.
3. **Size from throughput, not hope** — use the team's actual completed work over the last 3–5
   iterations. Forecast as a range, never a point.
4. **Reserve capacity** — support, defects, security remediation and review time are real work.
   A plan at 100% of capacity is a plan that fails.
5. **Sequence by dependency**, and make the critical path visible.
6. **Name the definition of done** (below) and hold it.

## Definition of Ready / Done

**Ready:** acceptance criteria written and testable · dependencies known · design or ADR decided
or deferred deliberately · security relevance assessed · sized by the implementing role · no
blocking open questions.

**Done:** acceptance criteria met and tested · code reviewed by a different role · tests passing in
CI (shown) · security review where flagged · documentation updated · traceability rows updated ·
deployed to at least staging · no new Sev1/Sev2.

## RAID log — `docs/sdlc/00-charter/raid-log.md`

```markdown
## Risks
| ID | Risk | L | I | Score | Response | Owner | Review | Status |
|----|------|---|---|-------|----------|-------|--------|--------|
| RSK-0007 | IdP vendor's EU tier may not meet residency (NFR-0011) | 3 | 5 | 15 | Mitigate: build in-house TOTP (ADR-0008) | solution-architect | 2026-09-20 | mitigating |
| RSK-0009 | Single data-engineer is a bus factor for migrations | 4 | 4 | 16 | Mitigate: pair on CR-0031; document runbook | project-manager | 2026-09-22 | open |

## Assumptions
| ID | Assumption | Impact if wrong | Validate by | Owner | Status |
|----|-----------|-----------------|-------------|-------|--------|
| ASM-0003 | Peak is 900 rps based on one prior flash sale | Capacity plan understates by unknown factor | replay 2nd event logs | performance-engineer | unvalidated |

## Issues  (a risk that has occurred)
| ID | Issue | Severity | Impact | Owner | Target | Status |
|----|-------|----------|--------|-------|--------|--------|
| ISS-0002 | Staging DB restore failed in drill | Sev2 | RTO unproven; blocks G5 criterion | devops-engineer | 2026-09-18 | open |

## Dependencies
| ID | Dependency | On whom | Needed by | Confirmed | Status |
|----|-----------|---------|-----------|-----------|--------|
| DEP-0004 | Security sign-off on ADR-0008 | security-officer | 2026-09-16 | yes | on track |
```

**Scoring:** likelihood 1–5 × impact 1–5. Score ≥ 15 escalates to the sponsor. Every risk has an
owner and a **review date** — an unreviewed risk log is a fiction within two weeks.

## Status report — lead with the decision needed

```markdown
## Status — Admin MFA — 2026-09-15

**Decision needed from you:** accept waiver W-0004 (manual erasure until 2026-10-15) so 2.14.0
can release on the 16th, or hold the release ~3 weeks for the automated erasure job.

**Status:** G4 passed with one waiver and one carried condition. 142/142 high-risk cases executed,
all passing. Performance validated at 2.9× current peak.

**Risks moving:** RSK-0009 (bus factor) unchanged at 16 — pairing starts this week.
**New:** ISS-0002, staging restore drill failed; RTO is unproven and this blocks a G5 criterion.
**Forecast:** release 2026-09-16 if the waiver is accepted; 2026-10-09 if not. Both assume
ISS-0002 is resolved by the 18th — if it is not, both dates move.
```

## Rules

- Forecasts are ranges with named assumptions, never a single date presented as a commitment.
- Estimates come from the role doing the work.
- A risk without an owner and a review date is not managed.
- A closed risk names the evidence that closed it.
- Report what is true, including bad news, early. A status report that has never contained bad news
  is not a status report.
- Scope changes are change records, not verbal agreements.
