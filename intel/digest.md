# Intel digest

What the weekly scout found, newest week first. Each week links to its inbox file and its pull
request. The scout keeps the twelve newest weeks. Written by `intel/scout.md`.

## Week of 2026-11-03

Claude Code moved from 2.1.311 to 2.1.317, and the platform notes brought no new models; the only model news is that fast mode for Opus 4.8 ends on 2026-11-30, which nothing in the factory uses. Two changes touch the guards: hooks that match Bash now also run on Monitor commands, and a new setting blocks writes outside the working directories. Subagents on a different model now take that model's effort level rather than the session's, so the next audit should check that the lean roles' `effort:` lines still apply. The stack-docs source was not read this run.

- Added pool tips P149 (block writes outside the working directories) and P150 (hooks on Monitor commands).
- Flagged for the next audit: the `effort:` frontmatter of the five lean roles (`plugins/sdlc-lean/agents/`).
- Inbox: `intel/inbox/2026-11-03.md`.

## Week of 2026-10-27

Claude Code moved from 2.1.303 to 2.1.311. The change worth the director's attention is that guard hooks failed open on Windows when Git Bash was missing, or when a PowerShell hook exited with code 2; this was fixed in 2.1.309 and 2.1.310, and it adds a second reason to keep every machine current, beside the fail-closed tip (P146). Compaction became safer, and a `SubagentStop` fix means the next audit should check sdlc-core's counters. The platform notes brought API version 2026-10-21 and new SDK majors, which the factory does not use. Last week's digest wrongly said the engineering blog had nothing since May: its 2026-10-13 post on source control was already there, and it has no bearing on the factory.

- Added pool tip P148: keep every machine on a current Claude Code version, because guard hooks failed open on Windows.
- Flagged for the next audit: the `SubagentStop` hook and the handoff check in plugins/sdlc-core, for double counts before 2.1.311.
- Inbox: `intel/inbox/2026-10-27.md`.

## Week of 2026-10-20

Claude Code 2.1.304 is the only release since last week, and nothing in it needs a change. After a compaction Claude is now sent the skill list again, skill hooks are capped at 1,024 per source, and several subagent and hook bugs are fixed, none of which the factory's plugins hit. The platform notes only say inference hooks are out of beta for Enterprise, with no new model or retirement. The engineering blog has a 2026-10-13 post on source control at Anthropic that agrees with the existing guard and review rules. The 2026-10-13 audit triggers stand, and P146 still waits on every machine running 2.1.295 or later.

- No pool tips, rules or plugin changes this week.
- Inbox: `intel/inbox/2026-10-20.md`.

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
