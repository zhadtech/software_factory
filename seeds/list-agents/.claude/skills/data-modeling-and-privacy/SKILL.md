---
name: data-modeling-and-privacy
description: Design schemas and safe migrations, classify data, and implement retention, deletion and subject-rights mechanics. Use when creating or changing a schema, writing a migration, handling personal data, or defining data-quality and lineage.
---

# Data Modelling, Migration & Privacy

## Classify before you model

Every field gets a class, because the class decides storage, access, logging, retention and deletion.

| Class | Examples | Consequences |
|---|---|---|
| Public | Product name, public price | None |
| Internal | Internal SKU, cost | Access control |
| Confidential | Contract terms, pricing agreements | Access control + encryption at rest |
| Personal | Name, email, IP, device ID, user ID | Lawful basis, retention, erasure, minimisation, access log |
| Special category | Health, biometric, race, religion, political, sexual orientation, trade union | Explicit basis, stricter access, often DPIA, frequently avoidable — challenge whether it is needed |
| Secret | Passwords, tokens, keys | Never in the DB in plain form; hash (Argon2id/bcrypt) or a key manager |

Record in `docs/sdlc/04-data/data-classification.md`:

```markdown
| Field | Store | Class | Lawful basis | Retention | Deletion path | Notes |
|---|---|---|---|---|---|---|
| users.email | primary DB | personal | contract | account life + 30d | erasure job → DSR-01 | also in audit log (7y, pseudonymised) |
| users.password_hash | primary DB | secret | contract | account life | cascade with user | Argon2id, params in ADR-0011 |
| events.ip_address | analytics | personal | legitimate interest | 90 days | partition drop | truncated to /24 at ingest |
```

## Modelling checklist

- [ ] Entities, relationships and cardinality match the business rules — check against the BA's rules catalogue
- [ ] Identity is explicit: natural vs surrogate key, and whether IDs are guessable (they usually should not be)
- [ ] Constraints enforce invariants in the database, not only in the application
- [ ] Nullability is deliberate; "unknown" and "not applicable" are different and often need distinct representation
- [ ] Temporal needs handled: created/updated, soft delete vs hard delete, history/audit tables, effective dating
- [ ] Denormalisation, where present, is deliberate and documented with the query it serves
- [ ] Every index names the query it exists for
- [ ] Multi-tenant: the tenant discriminator is on every table that holds tenant data, and is part of the keys/indexes

## Safe migration: expand → migrate → contract

```
Release N     EXPAND    add nullable column / new table / additive index (concurrently)
              code writes old AND new, reads old
Release N     BACKFILL  batched, resumable, throttled, idempotent; verify counts match
Release N+1   SWITCH    code reads new, still writes both
Release N+2   CONTRACT  stop writing old; drop it only after a full observation window
```

Rules:

- **Every migration states its rollback** and the behaviour of the *currently running* code
  mid-migration. Both versions must work with both schemas during the window.
- Never rename — add, backfill, switch, drop. A rename is an outage for anything still deployed.
- Never `DROP` in the same release that stops writing. If a drop is wrong, the data is gone.
- Large tables: additive and concurrent operations only; batch backfills with limits and sleeps;
  know your engine's locking behaviour before you run it.
- Test on a production-sized copy and **report the actual timing**, not an estimate.
- Backfills must be resumable and idempotent — they will be interrupted.

## Data quality

| Dimension | Check | Action on breach |
|---|---|---|
| Completeness | Required fields present; expected row counts | Alert + quarantine batch |
| Validity | Types, ranges, enums, formats, referential integrity | Reject to dead-letter |
| Uniqueness | Business keys unique; duplicates detected | Alert + dedupe rule |
| Timeliness | Freshness within the SLO window | Alert (see SLO skill) |
| Consistency | Cross-store reconciliation against source of truth | Alert + investigate |

Each check gets a threshold, a frequency, and an owner. A check with no action on breach is decoration.

## Privacy mechanics that must actually work

- **Minimisation:** the best control for a field is not collecting it. Challenge every personal field.
- **Erasure:** enumerate *every* location — primary DB, replicas, caches, search index, queues,
  object store, analytics, logs, backups, third-party processors. Document the mechanism for each,
  including "backups expire in N days" where in-place deletion is impossible.
- **Access/portability:** an export path that produces the data in a usable format.
- **Retention:** enforced by a job, not a policy document. Prove it ran.
- **Pseudonymisation:** separate the key material; note that it is reversible and therefore still
  personal data. Anonymisation is different, harder, and rarely achieved.
- **Transfers:** record every jurisdiction the data lands in, including backups and sub-processors.

## Guardrails

- Never copy production personal data to a non-production environment. Generate or mask.
- Never run a destructive migration outside a scratch database — production execution belongs to
  the DevOps Engineer under a change record.
- Never guess a retention period or lawful basis. Ask; log the gap.
- Report row counts and timings from real runs.
