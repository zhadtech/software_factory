# Now

Updated 2026-10-13. `bash scripts/test.sh` passes (11 checks).

Branch `phase2-sdlc-lean` (pull request #2, on top of #1) holds the `sdlc-lean` plugin, a README,
`scripts/new-project.sh`, and proposed rule R-TEAM-003 (hand each step to its role).
Three headless trials ran on 2026-10-13; R-TEAM-003's evidence says what each showed. Headless runs
cannot finish a builder step: background roles cannot ask for permission there.

Next action: the director runs one interactive trial in a fresh project made with
`scripts/new-project.sh`, with a plain request and no role names. Watch whether product writes
the steps and whether the main session stays out of role work. Then pick the first stack playbook.

| Phase | State |
|---|---|
| 0. Set up the repo | Done, except branch protection and archiving the old repos |
| 1. sdlc-core and the project template | Done. A cold session reads 9.4 KB before its first step |
| 2. Team profiles, first stack, evals | In progress: lean team built and tried; first stack and evals not started |
| 3. The intel loop | Not started |
| 4. Propagation, audits, metrics | Not started. How projects receive updates waits on the director |
