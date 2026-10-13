# Now

Updated 2026-10-13. `bash scripts/test.sh` passes (19 checks).

All four phases are built. Open pull requests, merge in this order, all against `main`: #4 (stacks
engine and TypeScript web), #5 (the other stacks), #6 (the scout, propagation, audits, metrics).
The first scout run and the first audit are in `intel/inbox/2026-10-13.md` and
`audits/2026-10-13.md`. A fresh project boots on 11,023 bytes.

The scout and audit routines exist; both first fire on Monday 2026-10-19, at 09:07 and 10:07
Asia/Saigon. They read their instructions from `main`, so #4 to #6 must be merged first.

Next action: after 2026-10-19, read the first routine runs (`RemoteTrigger list_runs`) and fix
what they stumbled on. Evals wait on the director's ceiling (`progress/waiting.md`).

| Phase | State |
|---|---|
| 0. Set up the repo | Done, except branch protection, which needs GitHub Pro |
| 1. sdlc-core and the project template | Done |
| 2. Team profiles, first stack, evals | Done except evals, which wait on the ceiling |
| 3. The intel loop | Done; the weekly routine first runs 2026-10-19 |
| 4. Propagation, audits, metrics | Done; the monthly audit routine first runs 2026-10-19 |
