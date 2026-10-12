---
name: test-strategy
description: Design a risk-based test strategy and test cases — levels, scope, environments, data, entry/exit criteria, and TC-numbered cases traced to requirements. Use when planning how a feature or release will be verified, deciding what to automate versus explore, or defining quality gates.
---

# Test Strategy & Case Design

## Procedure

1. **Enumerate what must be verified** — every `US-` acceptance criterion, every `NFR-`, every
   control test the Security Officer requires. Each gets a coverage decision; none is skipped silently.
2. **Rank by risk** — impact of failure × likelihood of failure. Concentrate depth where it is high;
   deliberately test less where it is low, and say so.
3. **Assign a level** to each check — push it as low as it can meaningfully live.
4. **Define environments and data** — where each level runs, and where the data comes from
   (synthetic or masked; never production personal data).
5. **Set entry and exit criteria** before execution, in measurable terms.
6. **Design cases** with IDs, preconditions, steps, expected results and traces.
7. **Split automate vs explore** and justify the split.
8. **Report** with passed / failed / blocked / not-executed kept distinct.

## Level selection

| Level | Verifies | Cost | Use for |
|---|---|---|---|
| Unit | One unit's logic in isolation | Lowest | Rules, calculations, validation, edge cases, error paths |
| Integration | Real collaborators (DB, queue, service) | Low | Persistence, transactions, adapters, migrations |
| Contract | Producer/consumer compatibility | Low | Every service or API boundary that can drift |
| API / system | A deployed slice end-to-end | Medium | Auth, permissions, workflows, error codes |
| E2E / UI | A full user journey through the UI | Highest | A small set of critical journeys only |
| Exploratory | The unknown | Human | New features, integrations, judgement surfaces |
| Non-functional | NFR budgets | Medium | Performance, resilience, accessibility, security |

If a check can pass at two levels, choose the lower one. E2E suites that duplicate unit coverage
are the main cause of slow, flaky pipelines.

## Test-case design techniques — pick deliberately

- **Equivalence partitioning** — one representative per class of input
- **Boundary value analysis** — min, min−1, min+1, max, max−1, max+1, zero, empty, null, one
- **Decision table** — for combinations of business rules; guarantees you cover the combinations
- **State transition** — for anything with a lifecycle; include invalid transitions
- **Pairwise** — when parameters combine combinatorially and full coverage is unaffordable
- **Error guessing** — informed by past defects in this codebase

## Test case template

```markdown
### TC-0102 — Admin login throttle locks after 5 failures
- **Traces to:** REQ-0042, US-0107, CTL-AC-05, THR-0003
- **Level:** API · **Type:** negative / security · **Priority:** high · **Automated:** AT-0044
- **Preconditions:** Admin `alex@example.test` exists, enrolled, not locked. Clock controllable.
- **Steps:**
  1. POST /admin/login with a wrong password — repeat 5 times within 10 minutes.
  2. POST /admin/login with the *correct* password.
- **Expected:** Step 1 returns 401 each time with a generic message (no user enumeration).
  After the 5th, the account is locked for 15 minutes and a security event is logged with the
  account id, source IP and timestamp. Step 2 returns 423/401 with the generic message —
  correct credentials do **not** bypass the lock.
- **Data:** synthetic account, deleted in teardown.
```

## Entry / exit criteria template

**Entry:** build deployed to the test environment; smoke suite green; test data seeded; known
blockers documented.
**Exit:** 100% of high-risk cases executed; ≥ 95% of all planned cases executed; zero open Sev1/Sev2;
every requirement has a coverage verdict; NFR results recorded; residual risk written in business terms.

## Reporting rules

- `passed` / `failed` / `blocked` / `not executed` are four different words. Never merge them.
- Line coverage is not requirement coverage. Report both, and lead with the latter.
- A green suite with untested requirements is a **red** report.
- State the residual risk in plain language a sponsor can act on.
