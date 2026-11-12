# Now

Updated 2026-11-12. `bash scripts/test.sh` passes (21 checks).

All four phases are done, evals included. Team work starts with `/sdlc-lean:team <request>`:
Claude Code starts sub-agents only when the user asks, and the command is the asking. Evals this
month: $6.81 of $20 (`evals/ledger.csv`); what they showed is in `evals/results.md`. The scout and
audit routines run each Monday at 09:07 and 10:07 Asia/Saigon.

The scout's first runs stumbled once: each started from `main` while the last digest was still
unmerged, so the 2026-10-27 and 2026-11-03 branches conflicted with the week before. The scout now
starts from the newest unmerged `intel/*` branch (`intel/scout.md`, step 1).

Branch `audit-findings-2026-11-12` (not pushed) carries what a process audit of one project found:
pool tips P152 to P159, three proposed rules (R-PLAN-007, R-TEAM-004, R-VER-007), the lean roles
cut steps by outcome and give a step one review round (sdlc-lean 0.3.0), and `sdlc-metrics` prints
the lines added to code, tests and paper (sdlc-core 0.4.0). The template's `AGENTS.md` grew from
9,925 to 10,953 bytes. Its evals ran on 2026-11-12 ($0.99; `evals/results.md`): the team command
passed 3 of 3, and the core-role-dispatch case failed 0 of 3 on a pass condition that is out of date.

Next action: the director reviews the draft pull request and answers `progress/waiting.md`. Then
give core-role-dispatch a pass condition that fits the template. After the next scout run, check that its branch started from the open digest and
merges cleanly. Before R-TEAM-003 can become active, run `/sdlc-lean:team` in a real project for
at least five steps and record what happened.

| Phase | State |
|---|---|
| 0. Set up the repo | Done, except branch protection, which needs GitHub Pro |
| 1. sdlc-core and the project template | Done |
| 2. Team profiles, first stack, evals | Done: lean team, `/sdlc-lean:team`, 17 stacks, four eval cases |
| 3. The intel loop | Done; the weekly routine has run since 2026-10-19 |
| 4. Propagation, audits, metrics | Done; no audit from the monthly routine is in `audits/` yet |
