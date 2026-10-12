# Now

Updated 2026-10-13. `bash scripts/test.sh` passes (10 checks, plugin validation included).

Branch `phase2-sdlc-lean` sits on top of `answers-2026-10-13` (pull request #1). It adds the
`sdlc-lean` plugin: five role agents, each under 2 KB, with `model`, `effort` and `disallowedTools`.
New projects from the template enable it. Its tests check the handoff block against sdlc-core's hook.

Next action: try the lean team on a real step in a throwaway project made from the template:
product writes the step, builder does it, reviewer reviews it. Record what breaks in
`progress/dead-ends.md` style notes here. Then pick the first stack playbook for phase 2.
Evals wait until the director sets the monthly ceiling.

| Phase | State |
|---|---|
| 0. Set up the repo | Done, except branch protection and archiving the old repos |
| 1. sdlc-core and the project template | Done. A cold session in a fresh template project reads 9.4 KB before its first step (target: under 40 KB) |
| 2. Team profiles, first stack, evals | In progress: lean team built; first stack and evals not started |
| 3. The intel loop | Not started |
| 4. Propagation, audits, metrics | Not started. How projects receive updates waits on the director |
