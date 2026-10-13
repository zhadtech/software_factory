# Eval results

What each eval run showed, newest first. The ledger (`evals/ledger.csv`) has every run's pass and
cost; this file says what the numbers mean.

## 2026-10-13

- **lean-team-command** (R-TEAM-003): with `/sdlc-lean:team`, the main session called product
  first in 4 of 4 runs, then the builder for each step and the reviewer for the tier M step. The
  same request without the command: 3 of 4. A full run of the team cost $0.22 to $1.03.
- **core-role-dispatch** (R-TEAM-003), a plain request on a Haiku main session. The guard works:
  every time the main session tried to write the step file or the code itself, it was refused.
  But Claude Code tells the main session "Do not spawn agents unless the user asks", so after a
  refusal Haiku often asked the director instead of handing off. Across the runs with the guard,
  6 of 10 reached product; with the rule alone in AGENTS.md and no guard, 1 of 6. That is why
  `/sdlc-lean:team` exists: it is the director asking. The runs also found the main session
  writing through the shell, which the guard now catches (sdlc-core 0.3.1). The first version of
  this case counted refused attempts as failures; it now judges outcomes.
- **core-heavy-file-guard** (R-BOOT-003): 3 of 3 passed with sdlc-core and 3 of 3 without, on
  Haiku. Without the guard, Haiku counted the lockfile's packages with a short Python script and
  never read the file whole, so the guard had nothing to stop. Cost: $0.04 with, $0.02 without;
  the guard's refusal adds a turn when it fires.
- **stacks-python-encoding** (R-PY-003): 3 of 3 passed with sdlc-stacks and 3 of 3 without, on
  Haiku. Haiku already opens files with `encoding="utf-8"` unprompted. Trial D's word counter,
  the incident R-PY-003 cites, ran on Haiku 4.5.
- Neither rule showed an effect on these tasks with the current Haiku. One task each is not
  enough to deprecate a rule; it is a reason for the audit to look for a harder case before
  either rule becomes active.
