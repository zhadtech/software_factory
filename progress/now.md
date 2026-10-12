# Now

Updated 2026-10-13. Branch `phase-1` (built on `phase-0`). `bash scripts/test.sh` passes.

Next action: wait for Zhad's answers to questions 1 and 2 in `progress/waiting.md`. Do not touch
fog_of_war before then: another session is changing it on branch `process/lean-boot` (S242, S243 on
2026-10-13: v0.1 archived, PLAN.md and PROGRESS.md cut to 16 KB, closed RAID rows moved). After that
branch merges, install sdlc-core there and add only what it lacks: `.claude/sdlc.json` with the 13
role names in `handoff_agents`, the `progress/` files, quiet `scripts/verify.sh`. Phase 1 is done
when a cold session reads under about 40 KB (10K tokens) before its first step.

Dry run on a local clone of fog_of_war at 792ef7f with the template config: the state card is
1,055 bytes and takes 1.1 s. Budgets flag AGENTS.md (197 lines, cap 150), INDEX.md (107 lines,
51 rows over 160 characters) and three docs over 150 lines, including raid-log.md at 593.

| Phase | State |
|---|---|
| 0, 1 | Built and tested here; GitHub steps and the fog_of_war install wait on Zhad |
| 2 to 4 | Not started. Phase 2 starts with the five-role lean team plugin |
