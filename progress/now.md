# Now

Updated 2026-10-13. Branch `phase-1` (built on `phase-0`). `bash scripts/test.sh` passes.

Next action: when Zhad says yes to question 2 in `progress/waiting.md`, install sdlc-core and the
template into fog_of_war on a new branch there, with the audit's day-one changes: archive v0.1
under `docs/archive/v0.1/`, split PROGRESS.md into the `progress/` files, quiet `scripts/verify.sh`,
`.claude/sdlc.json` with the 13 role names in `handoff_agents`. Then measure the bytes a cold
session reads before its first step. Phase 1 is done when that is under about 40 KB (10K tokens).
Until then, `claude --plugin-dir plugins/sdlc-core` loads the plugin without installing anything.

| Phase | State |
|---|---|
| 0. Set up the repo | Done, except the GitHub steps in `progress/waiting.md` |
| 1. sdlc-core and the project template | Built and tested here; fog_of_war install waits on Zhad |
| 2 to 4 | Not started. Phase 2 starts with the five-role lean team plugin |
