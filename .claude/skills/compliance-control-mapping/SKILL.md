---
name: compliance-control-mapping
description: Map regulatory or framework obligations (SOC 2, ISO 27001, GDPR, and similar) to implemented controls with named evidence. Use when establishing compliance scope, building or auditing the control matrix, assembling an evidence pack, or before a release in regulated scope.
---

# Compliance Control Mapping

## The rule that governs everything here

**A control exists only if you can point at evidence that it operates.** Intent, policy text and
someone's assurance are not evidence. An auditor asks "show me", and a path that does not resolve
is a failed control.

## Procedure

1. **Establish scope** — which frameworks apply, which systems and data are in scope, which
   jurisdictions, which period. If unstated, this is a blocking question, not an assumption.
2. **Import the obligations** as rows — criterion/clause ID and the actual requirement text reference.
3. **Map each to a control** you can name: what the system does, where, and who owns it.
4. **Name the evidence** and produce it into `docs/sdlc/06-security/evidence/`, dated.
5. **Define the test** — how the control's operation is verified, how often, by whom.
6. **Mark honestly**: implemented / partial / not implemented / not applicable (with reason).
   "Partial" and "not implemented" are normal, useful states. Overstating is the failure mode.
7. **Gaps become findings** (`SEC-####`) with owners and due dates.

## Control matrix — `docs/sdlc/06-security/control-matrix.md`

```markdown
| CTL | Obligation | Control statement | Implemented in | Owner | Test method | Frequency | Evidence | Status |
|-----|-----------|-------------------|----------------|-------|-------------|-----------|----------|--------|
| CTL-AC-02 | SOC2 CC6.1; ISO A.5.17 | Admin access requires MFA | `src/auth/mfa.py`, IdP policy | software-engineer | AT-0044 + config review | per release | evidence/mfa-config-2026-09-14.md | implemented |
| CTL-AC-05 | SOC2 CC6.1 | Failed-login throttle 5/10min | `src/auth/throttle.py` | software-engineer | TC-0102 | per release | evidence/throttle-test-2026-09-14.md | implemented |
| CTL-DE-01 | SOC2 CC7.2 | Auth anomaly alerting | alert rule `auth_failure_rate` | devops-engineer | alert fires in drill | quarterly | evidence/alert-drill-2026-08.md | partial — no drill yet |
| CTL-PR-03 | GDPR Art.17 | Erasure across all stores + backups | `jobs/erasure.py` | data-engineer | erasure drill | quarterly | — | **not implemented — SEC-0021** |
```

## Common obligation families (map to the framework's own IDs — these are the themes)

- **Access control** — least privilege, MFA, joiner/mover/leaver, privileged access review, session management
- **Change management** — approval, segregation of duties, testing before production, rollback, records
- **Secure development** — threat modelling, code review, dependency management, secrets handling
- **Logging & monitoring** — audit trail completeness, tamper resistance, retention, alerting, review
- **Data protection** — classification, encryption in transit and at rest, key management, retention, deletion
- **Privacy (GDPR-style)** — lawful basis, minimisation, purpose limitation, subject rights (access,
  rectification, erasure, portability, objection), transfers, sub-processors, breach notification clock, DPIA
- **Availability & resilience** — backup, tested restore, RTO/RPO, capacity, incident response
- **Vendor/third-party** — due diligence, contractual terms, ongoing monitoring
- **Business continuity** — plan, drill, evidence of the drill

## Evidence that actually works

| Good | Not evidence |
|---|---|
| Dated config excerpt + where it came from | "It's configured correctly" |
| Test run output with commit SHA and timestamp | "The tests cover it" |
| Pipeline log showing the approval gate | "Deploys require approval" |
| Restore-drill record with timings | "Backups run nightly" |
| Access review export with reviewer and date | "Access is least privilege" |
| Screenshot/export of the alert firing in a drill | "Alerting is in place" |

## Checklist

- [ ] Scope (frameworks, systems, data, jurisdictions, period) stated in writing
- [ ] Every in-scope obligation has a row — including the ones marked not-applicable, with reasons
- [ ] Every "implemented" row has an evidence path that **exists** (verify it)
- [ ] Every evidence item is dated and attributable
- [ ] Every gap has a `SEC-` finding with an owner and a due date
- [ ] Segregation of duties is demonstrable: author ≠ reviewer ≠ approver
- [ ] Waivers have compensating controls and expiry dates, and expired ones are reopened
- [ ] The matrix is maintained continuously, not assembled the week before the audit
