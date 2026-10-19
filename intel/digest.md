# Intel digest

What the weekly scout found, newest week first. Each week links to its inbox file and its pull
request. The scout keeps the twelve newest weeks. Written by `intel/scout.md`.

## Week of 2026-10-19

Claude Code moved from 2.1.296 to 2.1.303 and the platform notes added only fast-mode and tracing news, so this was a quiet week. The one change worth the director's attention is idle compaction: a conversation of 200K tokens or more that sits idle is now compacted on its own before the cache expires, and it can be turned off in settings. Hook input is now validated and prompt hooks are capped at 12 at a time, but the factory's hooks are unaffected. The Anthropic engineering blog still has nothing since May. The 2026-10-13 audit triggers stand, and the hook fail-closed tip (P146) still waits on every machine running 2.1.295 or later.

- Added pool tip P147: idle compaction and how to turn it off.
- Inbox: `intel/inbox/2026-10-19.md`.

## Week of 2026-10-13

Three new models arrived: Opus 5.5, Sonnet 5.5 and Haiku 5.5. The lean roles pick them up through
their model aliases with no change, but the charter treats a new model as a reason to recheck the
rules, and no rule has been checked against any model yet. Claude Code 2.1.295 lets a hook fail
closed, so a crashed guard would block instead of letting an action through; the factory should
adopt it once every machine runs 2.1.295 or later. The other changes need nothing from the factory.

- Added pool tip P146: make guard hooks fail closed.
- Flagged for the next audit: R-CTX-008, R-TEAM-003 and the reviewer role, against the new models.
- Inbox: `intel/inbox/2026-10-13.md`.
