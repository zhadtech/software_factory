# Now

Updated 2026-10-13. `bash scripts/test.sh` passes (15 checks).

Branch `phase2-stacks` sits on top of `phase2-sdlc-lean` (pull request #2). It adds the
`sdlc-stacks` plugin: a hook that adds a stack's rules the first time Claude touches a file they
cover, and `rules.json`, which `scripts/build-stacks.rb` writes from `registry/stacks.yaml` and the
registry's stack rules. The first stack is Python, with six proposed rules (R-PY-001 to R-PY-006).
A live session on 2026-10-13 got the rules on its first write of a .py file.

Next action: ask the director which stack comes next (TypeScript web, Expo, Swift, Godot,
PlatformIO and others), then add it as stack entries and rules that cite official docs.
Evals still wait on the monthly ceiling.

| Phase | State |
|---|---|
| 0. Set up the repo | Done, except branch protection and archiving the old repos |
| 1. sdlc-core and the project template | Done. A cold session reads 9.4 KB before its first step |
| 2. Team profiles, first stack, evals | Lean team done; stack engine and Python done; more stacks and evals next |
| 3. The intel loop | Not started |
| 4. Propagation, audits, metrics | Not started. How projects receive updates waits on the director |
