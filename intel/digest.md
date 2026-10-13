# Intel digest

What the weekly scout found, newest week first. Each week links to its inbox file and its pull
request. The scout keeps the twelve newest weeks. Written by `intel/scout.md`.

## Week of 2026-10-13

Three new models arrived: Opus 5.5, Sonnet 5.5 and Haiku 5.5. The lean roles pick them up through
their model aliases with no change, but the charter treats a new model as a reason to recheck the
rules, and no rule has been checked against any model yet. Claude Code 2.1.295 lets a hook fail
closed, so a crashed guard would block instead of letting an action through; the factory should
adopt it once every machine runs 2.1.295 or later. The other changes need nothing from the factory.

- Added pool tip P146: make guard hooks fail closed.
- Flagged for the next audit: R-CTX-008, R-TEAM-003 and the reviewer role, against the new models.
- Inbox: `intel/inbox/2026-10-13.md`.
