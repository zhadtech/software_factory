---
name: performance-testing
description: Model a realistic workload, run load/stress/soak tests, profile bottlenecks to a named cause, and forecast capacity and cost. Use when validating NFR budgets, diagnosing slowness, planning capacity, or before a high-traffic release.
---

# Performance Testing & Capacity

## Procedure

1. **Read the budgets** in `nfr.md`. No budget → escalate to the Solution Architect. Never invent a
   target to test against.
2. **Model the workload** and write down every assumption.
3. **Pin the environment** — results without environment identity are unusable.
4. **Baseline**, then vary one factor at a time.
5. **Run long enough** to clear warm-up and expose queueing and leaks.
6. **Analyse to a named cause** with profile or trace evidence.
7. **Recommend**, then **re-measure** after the fix. Unverified optimisation is not done.

## Workload model

```markdown
## Load model — checkout, peak hour
- Arrival: 420 rps sustained, 900 rps peak for 4 min (flash-sale pattern from 2026-06 logs)
- Mix: 60% browse · 25% search · 12% add-to-cart · 3% checkout
- Concurrency: ~3,400 sessions; think time 8 s ± 4 s
- Data: 12M products, 400k active carts, 2.1TB orders (production scale as of 2026-09)
- Cache: 70% hit rate at steady state (measured, not assumed)
- Growth horizon: 2.5× in 12 months (from PM forecast, 2026-09-01)

**Assumptions:** mix from 30 days of access logs; think time estimated — *unvalidated*;
flash-sale peak shape from one prior event only.
```

## Test types

| Type | Question | Duration |
|---|---|---|
| Baseline | What is normal, uncontended? | 10–15 min |
| Load | Do we meet budget at expected peak? | 30–60 min |
| Stress | Where is the knee, and how does it fail? | ramp to failure |
| Soak | Do we leak or degrade over time? | 4–24 h |
| Spike | Do we survive a sudden 10× and recover? | minutes |
| Capacity | What does one unit of capacity buy? | stepped ramp |

## Measurement discipline

- **Percentiles, never averages alone.** Report p50/p95/p99 and max. An average hides everything
  that matters.
- **Exclude warm-up explicitly** and say how much you dropped.
- **Beware coordinated omission** — open-model load generators, or corrected latency recording;
  closed-loop tools under-report latency exactly when the system is struggling.
- **One variable at a time.** Two changes, one measurement, zero conclusions.
- **Record environment identity**: instance types, replica counts, data volume, commit SHA,
  versions, network path, and whether the infrastructure is shared.
- **Repeat.** A single run is an anecdote.

## Bottleneck analysis

Attribute time with evidence before recommending anything: flame graph, query plan, trace waterfall,
pool-wait metric, GC log. Then check the usual suspects:

- Connection-pool saturation (the most common; look for pool-wait dominating the trace)
- N+1 queries and missing indexes — read the actual query plan
- Lock contention and long transactions
- Serialisation/allocation churn and GC pressure
- Unbounded result sets and missing pagination
- Sync I/O on a request thread; retries without backoff amplifying load
- Cold cache behaviour — a hot-cache pass is a false green

## Report format

```markdown
| NFR | Budget | Measured | Condition | Verdict |
|---|---|---|---|---|
| NFR-0009 | p95 ≤ 300 ms @ 500 rps | p95 = 240 ms | 500 rps, 30 min, warm | **met** |
| NFR-0009 | — | p95 = 4,200 ms | 600 rps | **knee at ~540 rps** |

**Bottleneck:** DB connection pool (size 10) saturates above ~540 rps; `db_pool_wait` is 87% of
p99 latency in the trace (evidence: `perf/trace-2026-09-12-0600.json`).
**Recommendation:** pool → 40 and add the missing index on `orders(tenant_id, created_at)`.
Expected: knee moves to ~1,400 rps. **Cost:** +1 DB replica, ~$180/mo.
**Re-test 2026-09-13:** knee at 1,310 rps, p95 = 260 ms @ 900 rps. NFR-0009 met at forecast peak.
**Headroom:** 2.9× current peak; sufficient for the 12-month 2.5× forecast.
```

## Guardrails

- Never publish a number you did not measure.
- Never load-test production or shared infrastructure without written authorisation and a
  coordinated window — load testing is an availability risk.
- Never test against a dataset far smaller than production; it produces a confident false pass.
- Never use production personal data — synthetic or masked only.
