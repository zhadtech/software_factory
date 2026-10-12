# SDLC Workflow & Phase Gates

Regulated mode: work moves forward only through **gates**. A gate is a recorded decision with
named approvers, written to `docs/sdlc/08-delivery/gate-reviews/`. The Project Manager chairs
every gate; the accountable role for that phase must sign; the Security Officer holds a veto
on G2, G4 and G5.

## Phase map

```
G0 Intake ──► G1 Requirements ──► G2 Design ──► G3 Build ──► G4 Verify ──► G5 Release ──► G6 Operate
```

| Gate | Phase        | Entry criteria                        | Exit artifacts                                          | Accountable        |
|------|--------------|---------------------------------------|---------------------------------------------------------|--------------------|
| G0   | Intake       | Request with a business sponsor        | `project-charter.md`, initial `raid-log.md`             | Project Manager    |
| G1   | Requirements | Charter approved                       | `brd.md`, `srs.md`, stories with AC, `glossary.md`      | Business Analyst   |
| G2   | Design       | Requirements approved, IDs issued      | `solution-design.md`, ADRs, `nfr.md`, `threat-model.md`, `data-model.md`, `user-flows.md` | Solution Architect |
| G3   | Build        | Design approved, threat model complete | Code merged behind review, `automation-design.md`, pipeline green | Software Engineer  |
| G4   | Verify       | Feature complete, unit coverage met    | `test-plan`, executed `test-cases`, `reports/`, perf results, security review report | QA Lead            |
| G5   | Release      | All G4 exits green, no open Sev1/Sev2  | `CR-####.md`, release notes, runbook, rollback plan, `control-matrix.md` evidence complete | DevOps Engineer    |
| G6   | Operate      | Deployed                               | SLO dashboard, incident + post-incident records, updated runbooks | DevOps Engineer    |

**A gate cannot be waived silently.** A waiver is a written entry in the gate review naming the
approver, the accepted risk, the expiry date, and the compensating control.

## Handoff graph

```
Project Manager ──charter, priorities──► Business Analyst
Business Analyst ──REQ/US + AC──────────► Solution Architect, UX Designer, QA Lead
UX Designer ──flows, wireframes─────────► Solution Architect, Software Engineer
Solution Architect ──design, ADR, NFR───► Software Engineer, Data Engineer, DevOps, Security Officer
Security Officer ──threats, controls────► Solution Architect, Software Engineer, QA Lead, DevOps
Data Engineer ──schema, migrations──────► Software Engineer, Performance Engineer
Software Engineer ──PR──────────────────► Code Reviewer ──approved PR──► DevOps Engineer
QA Lead ──test strategy, cases──────────► Automation Tester, Performance Engineer
Automation Tester ──suites, results─────► QA Lead, DevOps Engineer
Performance Engineer ──results, capacity─► Solution Architect, DevOps Engineer
DevOps Engineer ──pipeline, envs, release► everyone
Technical Writer ──docs, runbooks───────► users + operators
Everyone ──status, risk, blockers───────► Project Manager
```

## Handoff protocol

A handoff is not a message, it is an **artifact plus a claim**. When an agent hands off it must state:

1. **Artifact path(s)** produced or changed, with IDs.
2. **Status claim** — what is done, what is explicitly out of scope, what is unverified.
3. **Open items** — each one either an ID in the RAID log or an issue for the receiving role.
4. **Traceability delta** — which rows in `traceability.md` it added or changed.

The receiving agent starts by validating the handoff against its own *Inputs* section. If an
input is missing, it says so and stops rather than inventing the missing piece.

## Change control (post-G2)

Any change to an approved artifact requires:
- a `CR-####.md` change record with impact analysis across requirements, design, tests and controls;
- re-run of the affected gate's exit criteria;
- traceability update.

## Severity scale (shared vocabulary)

| Sev | Meaning                                                | Release impact         |
|-----|--------------------------------------------------------|------------------------|
| 1   | Data loss, breach, or total outage path                 | Blocks release         |
| 2   | Core journey broken, control missing, regulatory gap    | Blocks release         |
| 3   | Degraded function with workaround                       | Needs waiver           |
| 4   | Cosmetic / minor                                        | Backlog                |
