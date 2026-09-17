---
name: traceability-matrix
description: Build and maintain the requirement-to-design-to-code-to-test-to-control spine that proves coverage. Use when establishing traceability, before a phase gate, during impact analysis for a change, when preparing audit evidence, or when asked what a change affects.
---

# Traceability Matrix

## Why it exists

It answers four questions that are otherwise unanswerable: *Is everything we agreed built? Is
everything built agreed? If this changes, what breaks? Can we prove the control works?*

## The chain

```
REQ ──► US ──► ADR / design element ──► code (module, PR, commit)
                                    ──► TC / AT (test) ──► result + date
                                    ──► CTL (control) ──► evidence path
        NFR ─────────────────────────► measured result (performance / availability)
        THR ─────────────────────────► CTL ──► test ──► evidence
```

## Format — `docs/sdlc/traceability.md`

```markdown
| REQ | US | Design | Code | Test | Result | Control | Evidence | Status |
|-----|----|--------|------|------|--------|---------|----------|--------|
| REQ-0042 | US-0107 | ADR-0008, solution-design.md#auth | `src/auth/mfa.py`, PR #214 | TC-0101, TC-0102, AT-0044 | pass 2026-09-14 | CTL-AC-02 | evidence/mfa-config-2026-09-14.md | covered |
| REQ-0043 | US-0108 | ADR-0008 | — | TC-0103 | not executed | — | — | **gap: not built** |
| NFR-0009 | — | solution-design.md#latency | gateway config | perf/results-2026-09-12.md | p95 240 ms vs 300 ms budget | — | — | met |
```

`Status` is one of: `covered` · `partial` · `gap` · `accepted-untested` · `superseded`.
`accepted-untested` requires a named approver and a reason — it is a decision, not an omission.

## Procedure

1. **Seed** one row per requirement as soon as requirements are approved (Business Analyst).
2. **Each role appends its own column** when it produces its artifact — the matrix is maintained
   continuously, never reconstructed at the end. Reconstruction after the fact is where audits fail.
3. **Before a gate**, run the coverage checks below and report gaps by ID.
4. **For a change**, walk the chain in both directions to produce the impact list for the change
   record: which requirements, designs, tests and controls this touches.

## Coverage checks

- **Forward:** every REQ has at least one US, one test, and a result. Gaps = unbuilt or untested work.
- **Backward:** every shipped module traces to a REQ. Orphans = scope that nobody asked for, or a
  missing requirement — both worth knowing.
- **Control:** every applicable CTL has an implementation and an evidence path that exists on disk.
- **Threat:** every THR rated medium or above has a mitigation, a control, and a test.
- **NFR:** every NFR has a measured value and a verdict against its budget.

## Rules

- IDs are immutable. Supersede with a new ID and link; never renumber.
- A row is only `covered` when its test has a result and a date, not merely a test that exists.
- Broken links are defects. Check that every path referenced actually exists before a gate.
- The matrix is a text file in the repo so it diffs in review — never a spreadsheet nobody reads.
