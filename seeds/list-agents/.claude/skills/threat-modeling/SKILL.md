---
name: threat-modeling
description: Run a STRIDE threat model over trust boundaries and data flows, rate threats, and derive mitigations and controls with owners. Use at design time, when trust boundaries change, when personal data or authentication is involved, or before a security gate.
---

# Threat Modeling (STRIDE)

Do this at **design time**. A threat model produced after the build is a review, and reviews find
the cheap problems late instead of the expensive ones early.

## Procedure

1. **Scope** — what system, what version, what is explicitly out of scope, what the assets are.
   Name the crown jewels: the data whose compromise actually matters.
2. **Draw the data flow** with trust boundaries: external entities, processes, data stores, flows.
   Mermaid, in the repo. Every boundary crossing is where threats live.
3. **Enumerate with STRIDE per element and per boundary crossing.**
4. **Rate** each threat: likelihood (1–5) × impact (1–5). Be honest about likelihood — inflating
   everything to critical destroys the model's usefulness.
5. **Mitigate** — each threat rated ≥ medium gets a named mitigation, an owning role, and a control ID.
6. **State residual risk** for anything accepted, with the accepting human named.
7. **Hand mitigations to owners** and the control set to `compliance-control-mapping`.

## STRIDE prompts

| Category | Property violated | Ask |
|---|---|---|
| **S**poofing | Authentication | Can something claim an identity it does not have? Service-to-service too? |
| **T**ampering | Integrity | Can data be modified in transit, at rest, or in a client the user controls? |
| **R**epudiation | Non-repudiation | Can an actor deny an action? Is the audit log complete and tamper-resistant? |
| **I**nformation disclosure | Confidentiality | What leaks — in responses, errors, logs, metrics, timing, backups, URLs? |
| **D**enial of service | Availability | What is unbounded? Uploads, queries, retries, regex, concurrency, spend? |
| **E**levation of privilege | Authorisation | Can a user reach another tenant's or role's data? Is authz checked at *every* entry point? |

## The questions that find real bugs

- Is authorisation enforced at the data-access layer, or only in the UI/route layer?
- **Multi-tenancy:** can a valid ID from tenant A be used in a request authenticated as tenant B?
  (This is the single most common serious finding.)
- What happens on the second, concurrent, or replayed request? Any TOCTOU window?
- Which internal service trusts a header, claim or ID it did not verify itself?
- What does an error message, stack trace, or metric label reveal?
- Where does user input become a URL the server fetches (SSRF), a file path, a template, a query,
  a deserialised object, or a shell argument?
- Who can read the backups, the logs, the queue, the object store, the CI runner?
- What is the reset/recovery flow, and is it weaker than the primary auth path? (It usually is.)

## Threat record

```markdown
### THR-0003 — Credential stuffing against the admin login
- **Element:** `POST /admin/login`, boundary: internet → application
- **STRIDE:** Spoofing
- **Scenario:** An attacker replays credentials from a public breach corpus. No rate limit exists
  per account or per source; no second factor. A single success yields full customer-record access.
- **Likelihood:** 5 · **Impact:** 5 · **Rating:** Critical
- **Mitigations:**
  - M1 Second factor required for admin sessions → owner: software-engineer → CTL-AC-02 → REQ-0042
  - M2 Per-account throttle: 5 failures / 10 min, then 15 min lock → owner: software-engineer → CTL-AC-05
  - M3 Alert on failure-rate anomaly → owner: devops-engineer → CTL-DE-01
- **Verification:** TC-0101, TC-0102, AT-0044
- **Residual risk:** Session hijack post-authentication remains, tracked as THR-0009.
```

## Checklist

- [ ] Data flow diagram with every trust boundary marked, in the repo as text
- [ ] STRIDE applied to every boundary crossing and every data store
- [ ] Multi-tenant isolation examined explicitly
- [ ] Authentication *and* the recovery path both modelled
- [ ] Every threat ≥ medium has a mitigation, an owner, a control and a test
- [ ] Accepted risks name a human and an expiry
- [ ] Threats traced into `traceability.md`

## Boundaries

Model threats and design defences. Do not write working exploits beyond the minimum proof needed
to convince the team, and never test against systems outside the project's authorised scope.
