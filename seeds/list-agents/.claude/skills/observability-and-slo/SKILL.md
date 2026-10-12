---
name: observability-and-slo
description: Define SLIs, SLOs and error budgets, instrument the three signals, and write actionable alerts and runbooks. Use when setting availability or latency targets, building monitoring, reducing alert noise, or preparing for operations.
---

# Observability & SLOs

## Define the SLI from the user's experience

An SLI is a ratio of **good events to valid events**, measured where the user feels it — not
where it is convenient to instrument.

```
Availability SLI = successful requests / valid requests        (exclude 4xx caused by the client)
Latency SLI      = requests faster than threshold / valid requests
Quality SLI      = correct/complete responses / valid responses
Freshness SLI    = pipeline runs landing within the window / expected runs
```

## SLO table — `docs/sdlc/07-operations/slo.md`

```markdown
| Service | SLI | Target | Window | Error budget | Measured at | Owner |
|---|---|---|---|---|---|---|
| Auth API | successful / valid requests | 99.9% | 30d rolling | 43 min/month | gateway | devops-engineer |
| Auth API | requests < 300 ms | 95% | 30d rolling | 5% of requests | gateway | devops-engineer |
| Export job | runs landing < 15 min | 99% | 30d rolling | ~7 runs/month | job telemetry | data-engineer |
```

Targets come from `nfr.md`. A target nobody derived from a requirement is a number someone made up.

## Error budget policy — agree it before you need it

- Budget remaining → ship features.
- Budget < 25% → reliability work takes priority over features.
- Budget exhausted → feature freeze until burn stops; write a post-incident review.

This is the mechanism that makes an SLO more than decoration. Without a policy, an SLO is a poster.

## Instrumentation

**Metrics** — RED for request-driven services (Rate, Errors, Duration), USE for resources
(Utilisation, Saturation, Errors). Histograms for latency, never averages. Keep label cardinality
bounded — no user IDs, no request IDs, no unbounded paths as labels.

**Logs** — structured (JSON), with `trace_id`, `tenant_id`, `request_id`, and a stable `event`
field. Never log credentials, tokens, full personal records, or payment data. Retention and access
are controls; state them.

**Traces** — sample intelligently (always-on for errors and slow requests), propagate context
across every boundary including async work. A trace that stops at the queue answers nothing.

## Alerting rules

1. **Alert on symptoms, page on burn.** Page when the user is affected or the error budget is
   burning fast; ticket everything else.
2. Every alert has a **runbook link** and a **human decision** behind it. If the responder's only
   action is "acknowledge", delete the alert.
3. Multi-window burn rate beats a static threshold: fast burn (2% budget in 1 h) pages; slow burn
   (10% in 6 h) tickets.
4. Alert on saturation *trends* (disk full in 4 h), not only on breach.
5. Review noisy alerts monthly. An alert people routinely ignore is worse than no alert — it
   trains the ignore reflex.

## Runbook template — `docs/sdlc/07-operations/runbooks/auth-latency.md`

```markdown
# Alert: AuthLatencyBurn

**Symptom:** p95 /admin/login > 300 ms for 10 min. **User impact:** slow or timing-out logins.
**Severity:** Sev2 (Sev1 if error rate > 5%).

## Diagnose (in order, ~2 min each)
1. Dashboard `auth-overview` — is it latency only, or errors too?
2. DB connection pool saturation (`db_pool_wait_seconds`) — the usual cause.
3. Recent deploy? `kubectl rollout history …` — correlate with the change record.
4. Upstream IdP status.

## Act
- Pool saturated → scale replicas: `…` (safe, reversible, ~60 s)
- Recent deploy correlates → roll back per CR-####
- IdP degraded → enable degraded-mode banner, notify comms

## Verify
p95 returns below 300 ms within 10 min; error rate < 0.1%.

## Escalate
No improvement in 20 min → page the service owner. Data loss suspected → Sev1, page Security Officer.
```

## Checklist

- [ ] Every SLI is measured where the user experiences it
- [ ] Every SLO traces to an NFR
- [ ] An error budget policy exists and someone has agreed to it
- [ ] Every alert has a runbook and a decision; none is informational-only
- [ ] Logs are structured, correlated, and free of sensitive data
- [ ] Traces propagate across async boundaries
- [ ] Dashboards answer "is it broken, for whom, since when, and what changed"
