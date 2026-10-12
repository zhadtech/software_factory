---
name: technical-documentation
description: Write user guides, API/CLI reference, runbooks and release notes that are verified against actual behaviour. Use when documenting a shipped feature, writing reference material or operational procedures, or correcting documentation drift.
---

# Technical Documentation

## Pick the mode first — mixing them is the most common documentation failure

| Mode | Reader's situation | Shape | Never |
|---|---|---|---|
| **Tutorial** | Learning, no prior context | One guaranteed-to-work path, concrete, start to finish | Offer choices or explain alternatives |
| **How-to** | Has a specific task | Prerequisites → numbered steps → verification | Teach concepts mid-task |
| **Reference** | Needs a fact, fast | Exhaustive, consistently structured, scannable | Narrate or persuade |
| **Explanation** | Wants to understand why | Discussion, trade-offs, background | Include steps |

Ask: is the reader *learning*, *doing*, *looking up*, or *understanding*? Write that one.

## Verify against the system, not the spec

Run the command. Call the endpoint. Read the code for the actual default. Where documentation and
behaviour disagree, **the behaviour is the truth** and the gap is a defect report to the QA Lead.
Anything you could not execute is labelled `> **Unverified:** …`.

## API reference — the minimum that is actually useful

```markdown
### POST /v1/admin/mfa/enrol

Starts TOTP enrolment for the authenticated admin. Requires `admin` scope.
Rate limit: 5 requests / 10 minutes / account.

**Request**
| Field | Type | Required | Constraints | Default |
|---|---|---|---|---|
| `label` | string | no | ≤ 64 chars | account email |

**Response 201**
```json
{ "secret_uri": "otpauth://totp/…", "expires_at": "2026-09-15T10:12:00Z" }
```
`secret_uri` is shown once and is never retrievable again.

**Errors**
| Status | Code | Meaning | Action |
|---|---|---|---|
| 409 | `already_enrolled` | A factor already exists | Delete the existing factor first |
| 423 | `account_locked` | Too many failed verifications | Retry after the lock expires (15 min) |
| 429 | `rate_limited` | Enrolment rate limit hit | Honour `Retry-After` |

**Example** (verified 2026-09-15 against v2.14.0)
```bash
curl -X POST https://api.example.com/v1/admin/mfa/enrol \
  -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"label":"work phone"}'
```
```

## Procedure writing

Each step is one imperative action with an observable result. State prerequisites up front and the
expected end state at the bottom. Include the failure branch — "if you see X, it means Y, do Z."
A procedure nobody has executed is a draft and must say so.

## Release notes

Order matters — the reader is scanning for what will hurt them:

```markdown
## 2.14.0 — 2026-09-16   (CR-0031)

### Breaking changes
- Admin sessions now require a second factor. **Action required:** every admin must enrol before
  2026-09-20 or lose console access. See [Enrolling your second factor](…).

### Added
- TOTP enrolment with single-use recovery codes (US-0107)

### Fixed
- Login error messages no longer reveal whether an account exists (SEC-0018)

### Known issues
- Recovery-code download fails in Safari 17.2; copy the codes manually instead (QA-0412)
```

## Checklist

- [ ] Audience and mode named before writing
- [ ] Every procedure executed by you, with the documented result observed
- [ ] Every example real and runnable; output shown where useful; dated against a version
- [ ] Every parameter, default, limit and error code read from the source, never inferred
- [ ] Terminology matches `glossary.md` exactly — one term per concept
- [ ] Error conditions and recovery documented, not only the success path
- [ ] Unverified content explicitly marked
- [ ] Stale content corrected or deprecated with a date — never left in place silently
- [ ] Plain language: short sentences, active voice, no marketing tone
