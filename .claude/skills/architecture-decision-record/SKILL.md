---
name: architecture-decision-record
description: Record an architectural decision with its context, options, trade-offs and consequences, and set non-functional budgets as measurable numbers. Use when choosing a technology, drawing a boundary, making an expensive-to-reverse decision, or converting NFR adjectives into targets.
---

# Architecture Decision Records & NFR Budgets

## What deserves an ADR

Write one when the decision is **expensive to reverse**, **crosses team boundaries**, or **someone
will ask "why on earth" in a year**. Do not write one for a choice a competent engineer would make
the same way in five minutes; that is noise, and noise makes the real ADRs unreadable.

## ADR template — `docs/sdlc/02-architecture/adr/ADR-0008-mfa-provider.md`

```markdown
---
id: ADR-0008
title: Use a hosted TOTP provider rather than building MFA in-house
status: proposed | accepted | superseded by ADR-0015 | rejected
date: 2026-09-12
deciders: [solution-architect, security-officer, project-manager]
security-relevant: true
traces-to: [REQ-0042, NFR-0009, THR-0003]
---

## Context
What forces are at play: requirements, constraints, NFR budgets, team capability, regulatory
obligation, existing systems, deadline. State facts, not preferences. If a number drives the
decision, put the number here.

## Options considered

### Option A — Hosted TOTP provider
- Pros: ~2 weeks to ship; provider holds the seed material; SOC 2 attested; supports recovery codes.
- Cons: $X/user/month; dependency on provider availability (their SLA: 99.9%); data leaves our region.
- Exit cost: re-enrolment of every user (~1 day of work, but user-visible).

### Option B — In-house TOTP
- Pros: no per-user cost; seeds stay in our KMS; no residency question.
- Cons: ~6 weeks; we own the recovery flow, the rate limiting and the audit logging; higher
  ongoing security review burden.
- Exit cost: low.

### Option C — Do nothing (keep single factor)
- Rejected: violates REQ-0042 and leaves THR-0003 unmitigated.

## Decision
Option B — in-house TOTP. The residency constraint (NFR-0011, data must remain in-region) rules
out the provider's EU-only tier at our price point, and the seed material is special-category
adjacent under our classification.

## Consequences
- **Positive:** no residency exception needed; no per-user cost at our growth forecast.
- **Negative:** +4 weeks to the G3 date; the team now owns recovery-flow security, which becomes
  a recurring review item.
- **Follow-up:** CTL-AC-02 evidence must include the rate-limit configuration; PE to load-test
  the verification endpoint (it sits on the login hot path).
- **Reversal cost:** low — the interface is behind `AuthFactor`, swap is ~1 sprint.
```

## NFR budget format — `docs/sdlc/02-architecture/nfr.md`

Every NFR is **metric + target + condition + measurement method + owner**. No adjectives.

```markdown
| ID | Category | Metric | Target | Under condition | Measured by | Owner |
|----|----------|--------|--------|-----------------|-------------|-------|
| NFR-0009 | Latency | p95 API response | ≤ 300 ms | 500 rps sustained, warm cache | k6 at gateway | performance-engineer |
| NFR-0010 | Availability | Monthly successful-request ratio | ≥ 99.9% | excluding announced windows | SLO dashboard | devops-engineer |
| NFR-0011 | Residency | Personal data at rest location | eu-west-1 only | all stores + backups | IaC review + evidence | security-officer |
| NFR-0012 | Recovery | RTO / RPO | 4 h / 15 min | region-level failure | restore drill | devops-engineer |
```

## Checklist

- [ ] One decision per ADR; the title states the decision, not the topic
- [ ] At least two real options, with honest costs — a single-option ADR is a rationalisation
- [ ] Rejected options say *why* rejected, in terms of the forces in Context
- [ ] Consequences include the negative ones and the follow-up work
- [ ] Reversal cost stated
- [ ] Security-relevant decisions flagged and routed to the Security Officer
- [ ] Every NFR has a number and a measurement method — never an adjective
- [ ] Unknown targets are open questions to the sponsor, never invented
