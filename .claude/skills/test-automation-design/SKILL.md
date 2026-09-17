---
name: test-automation-design
description: Build automated test suites that are fast, deterministic and maintainable, and wire them into CI with a flake policy. Use when implementing test cases, building a regression suite, adding CI test stages, or fixing flaky or slow tests.
---

# Test Automation Design

## Procedure

1. **Detect the existing setup** — runner, assertion library, fixture style, E2E tool, CI stages.
   Follow it. Introducing a second framework for the same job is a maintenance defect.
2. **Take the case from the QA Lead**; confirm the level it belongs at. Push it down if it can live lower.
3. **Write it failing first.** For a defect, reproduce before fixing. For a feature, assert the
   acceptance criterion.
4. **Make it deterministic** before you make it comprehensive.
5. **Run it three times and in a different order.** Flake shows up in repetition, not in one green run.
6. **Wire into CI** at the right stage, with artifacts on failure.
7. **Report** counts, runtime, and anything quarantined with its expiry.

## Determinism rules

| Source of flake | Fix |
|---|---|
| `sleep` / fixed waits | Wait for a condition or an event, with a timeout |
| Real clock | Inject or freeze time |
| Random data | Seed it, and print the seed on failure |
| Shared mutable fixtures | Per-test setup/teardown, or a factory returning fresh data |
| Test order dependence | Each test creates what it needs; run in random order in CI to prove it |
| Network to third parties | Stub at the boundary; contract-test the real thing separately |
| Parallel collisions | Unique identifiers per test; no fixed IDs, ports or file paths |
| Animation / async UI | Wait for a stable state, disable animations in the test profile |

**Never fix flake with a retry.** A retry hides a real race that your users will hit.

## Locator strategy (UI)

Preferred order: accessible **role + name** → `data-testid` → stable semantic attribute →
(last resort, documented) text content. Never a CSS chain or an index-based path — these encode
the DOM's current accident, not the user's intent.

## Assertion rules

- Assert observable behaviour and contract, never private internals.
- One logical behaviour per test; a test that can fail for five reasons tells you nothing.
- Failure messages must identify the behaviour, not just show a diff of two objects.
- Negative tests assert the *specific* failure (status, code, message class), not merely "it threw".

## Structure

```
tests/
├── unit/                     # fast, isolated, the bulk of the suite
├── integration/              # real DB/queue, containerised, per-test isolation
├── contract/                 # provider + consumer compatibility
├── e2e/                      # a handful of critical journeys only
│   ├── pages/                # page objects: locators + actions, no assertions
│   └── journeys/             # the tests: assertions live here
└── fixtures/                 # factories over static dumps; no production data, ever
```

## CI staging

```
lint + typecheck  (seconds)   → fail fast
unit              (< 2 min)   → parallel
integration       (< 10 min)  → containerised services
contract          (< 5 min)
security scans                → dependency + secret scan as gates
e2e (critical)    (< 15 min)  → parallel shards, traces/screenshots/video on failure
nightly           → full e2e, soak, cross-browser, mutation testing if used
```

## Flake policy

1. A flaky test is quarantined the day it is identified — with an **owner and an expiry date**.
2. Quarantine is not a fix; it is a timer. Expired quarantine = the test is fixed or deleted.
3. Quarantined tests are listed in every report. A "green" suite with quarantined tests is reported
   as green-with-caveats, never as green.

## Checklist

- [ ] Every test maps to a `TC-`/`US-` ID
- [ ] Asserts behaviour, not implementation
- [ ] Deterministic: no sleeps, no order dependence, controlled clock and randomness
- [ ] Passes three consecutive runs and in randomised order
- [ ] Runtime stated; slow tests justified or moved down a level
- [ ] Failure output is diagnosable without a local reproduction
- [ ] No credentials, tokens or personal data in test code or fixtures
- [ ] Never targets production without explicit written authorisation
