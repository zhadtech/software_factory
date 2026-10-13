# Now

Updated 2026-10-13. `bash scripts/test.sh` passes (19 checks).

All four phases are built. Open pull requests, merge in this order, all against `main`: #4 (stacks
engine and TypeScript web), #5 (the other stacks), #6 (the scout, propagation, audits, metrics).
The first scout run and the first audit are in `intel/inbox/2026-10-13.md` and
`audits/2026-10-13.md`. A fresh project boots on 11,023 bytes.

Next action: once the director gives Claude's GitHub app access to the repo, create the routines
with the schedule skill (crons `7 2 * * 1` and `7 3 * * 1` UTC; the audit prompt stops after the 7th).

| Phase | State |
|---|---|
| 0. Set up the repo | Done, except branch protection, which needs GitHub Pro |
| 1. sdlc-core and the project template | Done |
| 2. Team profiles, first stack, evals | Done except evals, which wait on the ceiling |
| 3. The intel loop | Built and run once; the weekly routine waits on the director |
| 4. Propagation, audits, metrics | Built; the monthly routine waits on the director |
