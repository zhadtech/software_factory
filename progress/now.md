# Now

Updated 2026-10-13. `bash scripts/test.sh` passes (16 checks).

Branch `phase2-stack-ts` (on top of `phase2-stacks`, pull request #3) adds the TypeScript web stack:
three layers that combine through markers. TypeScript (R-TS-001 to 004) turns on with a
`tsconfig.json`, React (R-REACT-001 to 004) when `package.json` lists react, and Next.js
(R-NEXT-001 to 003) with a `next.config.*` or next in `package.json`. All rules are proposed and
cite official docs. `sdlc-stacks` is at 0.2.0 with Python and these three stacks.

Next action: ask the director which stack comes next: Expo for mobile, Swift for iOS, Electron or
Tauri for desktop, PlatformIO for IoT, or Godot or Unity for games. Evals still wait on the
monthly ceiling.

| Phase | State |
|---|---|
| 0. Set up the repo | Done, except branch protection and archiving the old repos |
| 1. sdlc-core and the project template | Done. A cold session reads 9.4 KB before its first step |
| 2. Team profiles, first stack, evals | Lean team done; stacks: Python and TypeScript web done; more stacks and evals next |
| 3. The intel loop | Not started |
| 4. Propagation, audits, metrics | Not started. How projects receive updates waits on the director |
