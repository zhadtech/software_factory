# Now

Updated 2026-10-13. `bash scripts/test.sh` passes (12 checks).

Branch `phase2-sdlc-lean` (pull request #2, on top of #1) holds the `sdlc-lean` plugin, a README,
`scripts/new-project.sh`, and R-TEAM-003 (hand each step to its role), now on trial and enforced
by the sdlc-core 0.2.0 role-work guard. sdlc-core also checks plan/queue.json against its schema.
Four trials ran on 2026-10-13, the last one interactive; R-TEAM-003's evidence says what each
showed. In none did the main session call a role unless the request named it.

Next action: the director runs one more interactive trial in a fresh project made with
`scripts/new-project.sh`, with a plain request. A headless check on 2026-10-13 showed the guard
blocking the main session from writing code while product and builder wrote their files.

| Phase | State |
|---|---|
| 0. Set up the repo | Done, except branch protection and archiving the old repos |
| 1. sdlc-core and the project template | Done. A cold session reads 9.4 KB before its first step |
| 2. Team profiles, first stack, evals | In progress: lean team built and tried; first stack and evals not started |
| 3. The intel loop | Not started |
| 4. Propagation, audits, metrics | Not started. How projects receive updates waits on the director |
