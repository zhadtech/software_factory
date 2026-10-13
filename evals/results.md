# Eval results

What each eval run showed, newest first. The ledger (`evals/ledger.csv`) has every run's pass and
cost; this file says what the numbers mean.

## 2026-10-13

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
