# PLAN

**Task:** <one sentence, from the user>
**Goal:** <what is true when this is finished>
**Done when:** <objective, checkable — a command, a behavior, an artifact>
**Out of scope:** <explicitly, so no one wanders>

**Assumptions:** <anything chosen rather than told; if wrong, the plan changes>

---

## Steps

Each step: small enough to finish in one sitting, with a verification that either
passes or doesn't. No step may be "and then clean things up".

- [ ] **S1.** <action>
      - touches: `path/to/file.ts:88-140`
      - verify: `npm test -- auth`
- [ ] **S2.** <action>
      - touches: `…`
      - verify: `…`
      - depends on: S1
- [ ] **S3.** <action>
      - touches: `…`
      - verify: `…`

---

## Open questions

- <blocking? then ask before starting. non-blocking? state the assumption in the step and continue>

---

## Revision log

- `<date>` — plan created
- `<date>` — S4 split into S4a/S4b after <reason>
