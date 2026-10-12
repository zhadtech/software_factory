# RACI Matrix

**R** Responsible (does the work) · **A** Accountable (one per row, owns the outcome) ·
**C** Consulted (input required before done) · **I** Informed (told after)

Abbreviations: PM, BA, SA (Solution Architect), SWE, CR (Code Reviewer), QA (QA Lead),
AT (Automation Tester), SO (Security Officer), DO (DevOps/SRE), UX, TW (Technical Writer),
DE (Data Engineer), PE (Performance Engineer).

| Activity                          | PM | BA | SA | SWE | CR | QA | AT | SO | DO | UX | TW | DE | PE |
|-----------------------------------|----|----|----|-----|----|----|----|----|----|----|----|----|----|
| Project charter & scope           | A  | R  | C  | I   | I  | I  | I  | C  | I  | I  | I  | I  | I  |
| Requirements & acceptance criteria| C  | A  | C  | C   | I  | C  | I  | C  | I  | C  | I  | C  | I  |
| Solution design & ADRs            | I  | C  | A  | C   | C  | I  | I  | C  | C  | C  | I  | C  | C  |
| Non-functional requirements       | C  | C  | A  | I   | I  | C  | I  | C  | C  | I  | I  | C  | R  |
| Threat model & controls           | I  | C  | C  | C   | C  | C  | I  | A  | C  | I  | I  | C  | I  |
| Data model & privacy classification| I | C  | C  | C   | I  | I  | I  | C  | I  | I  | I  | A  | C  |
| UX flows, wireframes, a11y        | I  | C  | C  | C   | I  | C  | I  | I  | I  | A  | C  | I  | I  |
| Implementation                    | I  | I  | C  | A   | C  | I  | I  | I  | C  | I  | I  | R  | I  |
| Code review & merge gate          | I  | I  | C  | C   | A  | I  | I  | C  | I  | I  | I  | I  | I  |
| Test strategy & quality gates     | C  | C  | C  | C   | I  | A  | R  | C  | I  | I  | I  | I  | C  |
| Test automation & CI suites       | I  | I  | I  | C   | C  | C  | A  | I  | C  | I  | I  | I  | C  |
| Performance & capacity validation | I  | I  | C  | C   | I  | C  | C  | I  | C  | I  | I  | C  | A  |
| CI/CD, IaC, environments          | I  | I  | C  | C   | I  | I  | C  | C  | A  | I  | I  | C  | C  |
| Security review & sign-off        | C  | I  | C  | C   | C  | C  | I  | A  | C  | I  | I  | C  | I  |
| Release go/no-go                  | A  | I  | C  | C   | I  | C  | I  | C  | R  | I  | I  | I  | C  |
| Deployment & rollback             | I  | I  | I  | C   | I  | I  | I  | C  | A  | I  | I  | C  | I  |
| Documentation & runbooks          | I  | C  | C  | C   | I  | C  | I  | C  | C  | C  | A  | C  | C  |
| Incident response & post-incident | C  | I  | C  | R   | I  | I  | I  | R  | A  | I  | C  | C  | C  |
| Audit evidence package            | C  | C  | C  | I   | I  | C  | I  | A  | R  | I  | C  | C  | I  |
| Status, risk & stakeholder comms  | A  | C  | C  | C   | I  | C  | I  | C  | C  | I  | C  | C  | C  |

## Rules that follow from this matrix

1. **One A per row.** If two agents both think they own an outcome, the PM resolves it by
   pointing at this table.
2. **C means blocking.** An artifact is not done until every C on its row has responded. "No
   objection" is a valid response and must be recorded.
3. **The Security Officer's A on controls is a veto**, not a preference. A release with an
   unresolved Sev1/Sev2 security finding does not pass G5 without a written, expiring waiver.
4. **The Code Reviewer never has R on implementation.** Reviewer and author are always different
   agents; the reviewer does not fix the code it reviews.
