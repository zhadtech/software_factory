---
name: ci-cd-and-release
description: Design CI/CD pipelines, environment and secrets handling, and execute releases with change records, verification and rollback. Use when building or fixing a pipeline, defining environment promotion, preparing a release, or writing a rollback plan.
---

# CI/CD & Release Engineering

## Pipeline shape

```
commit
 ├─ lint + typecheck            seconds     fail fast
 ├─ unit tests                  < 2 min     parallel
 ├─ build artifact              once        immutable, digest-addressed, SBOM emitted
 ├─ integration + contract      < 10 min
 ├─ security gates              dependency scan · secret scan · IaC scan · licence check
 ├─ publish artifact            signed, provenance attached
 ├─ deploy → staging            same artifact, different config
 ├─ e2e + performance smoke
 ├─ manual approval             REQUIRED in regulated scope; recorded, segregated from the author
 └─ deploy → production         progressive · verified · reversible
```

**Build once, promote the same artifact.** Rebuilding per environment means production runs
something that was never tested.

## Configuration & secrets

- Config comes from the environment, never from a branch. Same image everywhere.
- Secrets come from a secret manager, injected at runtime; never in the repo, image layers, CI
  variables that get echoed, or logs.
- Prefer short-lived, workload-identity credentials over long-lived keys.
- CI runners: least privilege, no production write access from a PR-triggered job, and no secrets
  exposed to jobs triggered by forks.
- A committed secret is a Sev1 incident: **rotate first**, then purge from history.

## Release plan template — `docs/sdlc/08-delivery/change-records/CR-0031.md`

```markdown
---
id: CR-0031
change: Admin MFA enforcement
version: 2.14.0    commit: 9f3c1ab    artifact digest: sha256:…
window: 2026-09-16 02:00–03:00 UTC    risk: medium
approvals: [project-manager (go/no-go), security-officer (CTL-AC-02), qa-lead (G4)]
---

## Pre-checks
- [ ] G4 exit criteria met; no open Sev1/Sev2
- [ ] Staging soak ≥ 24 h, error rate within budget
- [ ] Backup verified restorable (drill: 2026-09-10)
- [ ] Rollback rehearsed in staging

## Sequence
1. Migration `0043_add_mfa_factors` — additive only, safe with current code running.
2. Deploy 2.14.0 to 10% (canary), flag `mfa_required=off`.
3. Verify (below). Hold 30 min.
4. Ramp 100%. Verify. Hold 60 min.
5. Enable `mfa_required=on` for the admin cohort.

## Verification — named signals, not vibes
- p95 `/admin/login` ≤ 300 ms (dashboard: auth-overview)
- 5xx rate on auth routes ≤ 0.1%
- `mfa_enrolment_success_total` increasing; `mfa_verify_error_ratio` < 2%
- No new error signature in the auth log stream

## Rollback
- **Trigger:** 5xx > 1% for 5 min, OR p95 > 800 ms for 10 min, OR any Sev1.
- **Procedure:** set `mfa_required=off` (instant, no deploy) → redeploy 2.13.4 → confirm signals.
- **Irreversible:** migration 0043 is additive and stays; no data is destroyed. Enrolled factors
  persist and remain valid on re-release.
- **Rollback time objective:** 10 minutes from trigger to stable.
```

## Deployment strategies

| Strategy | Use when | Cost |
|---|---|---|
| Rolling | Stateless, backward-compatible | Cheap; both versions live at once — contracts must tolerate it |
| Blue/green | Need instant, complete rollback | Double capacity during the switch |
| Canary | Risk warrants real-traffic evidence | Needs per-cohort metrics to be meaningful |
| Feature flag | Decouple deploy from release | Flag debt — every flag needs a removal date |

## Database + code ordering

Deploy so that **either version works with either schema** during the window:
expand (additive migration) → deploy code that writes both/reads new → backfill → verify →
contract (remove old) in a **later** release. Never contract in the same release that stops using
the column.

## Checklist

- [ ] Pipeline runs green from a clean checkout — output shown, not asserted
- [ ] One artifact, promoted; digest recorded in the change record
- [ ] Security gates are blocking, not advisory
- [ ] Production deploy requires a recorded approval, segregated from the author
- [ ] Verification steps name specific signals and thresholds
- [ ] Rollback is rehearsed, timed, and its trigger conditions are pre-agreed
- [ ] Anything irreversible is stated explicitly
- [ ] The change record is complete before the change is called done

**Never** execute a production deploy or a destructive infrastructure command without explicit
human confirmation of that specific action.
