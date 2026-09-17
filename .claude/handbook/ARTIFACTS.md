# Artifact Conventions

Every agent writes to a predictable path inside the **target project** repo. No agent invents
a new location. If a directory does not exist, create it.

```
docs/sdlc/
├── 00-charter/
│   ├── project-charter.md
│   └── raid-log.md                  # Risks, Assumptions, Issues, Dependencies
├── 01-requirements/
│   ├── brd.md                       # Business Requirements Document
│   ├── srs.md                       # Software Requirements Specification
│   ├── stories/US-####-slug.md      # one file per user story
│   └── glossary.md
├── 02-architecture/
│   ├── solution-design.md
│   ├── nfr.md                       # Non-functional requirements + budgets
│   └── adr/ADR-####-slug.md         # one file per decision
├── 03-design/
│   ├── user-flows.md
│   ├── wireframes/
│   └── accessibility-report.md
├── 04-data/
│   ├── data-model.md
│   ├── data-classification.md       # PII/PHI inventory, retention, lawful basis
│   └── migrations/
├── 05-quality/
│   ├── test-strategy.md
│   ├── test-plan-<release>.md
│   ├── test-cases/TC-####-slug.md
│   ├── automation-design.md
│   └── reports/
├── 06-security/
│   ├── threat-model.md
│   ├── control-matrix.md            # control ID -> implementation -> evidence
│   ├── evidence/                    # artifacts an auditor can read
│   ├── findings/SEC-####-slug.md
│   └── review-reports/
├── 07-operations/
│   ├── pipeline.md
│   ├── environments.md
│   ├── slo.md
│   ├── runbooks/
│   └── performance/
├── 08-delivery/
│   ├── sprint-<n>.md
│   ├── gate-reviews/GATE-<phase>-<date>.md
│   ├── change-records/CR-####.md
│   └── release-notes/
└── traceability.md                  # the spine: REQ -> design -> code -> test -> control
```

## Identifier scheme

| Prefix | Meaning          | Owner              |
|--------|------------------|--------------------|
| `REQ-` | Requirement      | Business Analyst   |
| `US-`  | User story       | Business Analyst   |
| `NFR-` | Non-functional   | Solution Architect |
| `ADR-` | Design decision  | Solution Architect |
| `TC-`  | Test case        | QA Lead            |
| `AT-`  | Automated test   | Automation Tester  |
| `THR-` | Threat           | Security Officer   |
| `CTL-` | Control          | Security Officer   |
| `SEC-` | Security finding | Security Officer   |
| `CR-`  | Change record    | DevOps Engineer    |
| `RSK-` | Risk             | Project Manager    |

IDs are **immutable once issued**. Supersede, never renumber — auditors follow the number.

## Front matter on every artifact

```yaml
---
id: REQ-0042
title: Multi-factor authentication for admin console
status: draft | in-review | approved | superseded
owner: business-analyst
version: 1.2
updated: 2026-09-15
approvers: [project-manager, security-officer]
traces-to: [US-0107, NFR-0009, CTL-AC-02]
---
```

`status` moves only through a gate review. An agent may author and revise; only the
**Project Manager** records approval, and only after the accountable role signs off
(see [RACI.md](RACI.md)).

## Writing rules

- State facts, not intentions. "The API enforces rate limiting at 100 req/min" — not "we plan to".
- Every claim of compliance links to evidence in `06-security/evidence/`.
- Unknowns become entries in the RAID log, never silent gaps or invented detail.
- Diffs over rewrites: amend the artifact and bump `version`; keep the ID.
