# Now

Updated 2026-10-13. `bash scripts/test.sh` passes.

All four phases are built and on `main` (#1 to #6). The first scout run and the first audit are in
`intel/inbox/2026-10-13.md` and `audits/2026-10-13.md`. A fresh project boots on 11,023 bytes.
The scout and audit routines first fire on Monday 2026-10-19, at 09:07 and 10:07 Asia/Saigon.

Next action: after 2026-10-19, read the first routine runs (`RemoteTrigger list_runs`) and fix
what they stumbled on. Evals wait on the director's ceiling (`progress/waiting.md`).

| Phase | State |
|---|---|
| 0. Set up the repo | Done, except branch protection, which needs GitHub Pro |
| 1. sdlc-core and the project template | Done |
| 2. Team profiles, first stack, evals | Done except evals, which wait on the ceiling |
| 3. The intel loop | Done; the weekly routine first runs 2026-10-19 |
| 4. Propagation, audits, metrics | Done; the monthly audit routine first runs 2026-10-19 |
