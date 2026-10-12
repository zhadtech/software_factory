# Now

Updated 2026-10-13.

## Next action

Start phase 1 on a new branch from `phase-0`: build the `sdlc-core` plugin and the project
template. First read the day-one changes in the
Agent Team Process Audit, then package the
six hooks it names (state card, heavy file, output trim, budget, handoff, compaction), the
quiet-verify and size-budget templates, the queue schema and the `next-step` script.
Done when a cold fog_of_war session reads under 10K tokens before its first step.
Installing into fog_of_war changes that repo, so ask Zhad first.

## Phases

| Phase | State |
|---|---|
| 0. Set up the repo | Done on branch `phase-0`, except the GitHub steps below |
| 1. sdlc-core and the project template | Not started |
| 2. Team profiles, first stack, evals | Not started |
| 3. The intel loop | Not started |
| 4. Propagation, audits, metrics | Not started |

## Waiting on Zhad

1. Create the private GitHub repo `zhadtech/software_factory` and push `phase-0` as `main`?
   Recommended: yes. Blocks: branch protection and the pull request flow.
2. Turn on branch protection for `main`, requiring Zhad's review to merge? Recommended: yes,
   right after the first push. Blocks: "agents propose, Zhad merges" is only a rule until then.
3. Archive `zhadtech/agi-standards` and `zhadtech/list-agents` on GitHub so they are read-only?
   Recommended: yes, after the factory repo is pushed. Blocks: nothing yet.
4. What is the monthly ceiling for eval spending? Recommended: start small, for example the cost
   of one long session, and raise it with evidence. Blocks: phase 2 evals.

## Notes

- Phase 0 check: `ruby scripts/check-registry.rb seeds/agi-standards/AGENTS.md ../fog_of_war/AGENTS.md`
  printed `registry ok: 43 rules (43 active, 43 never checked against a model), 145 pool tips
  (50 promoted), 2 rule file(s) covered` on 2026-10-13.
- All 43 seeded rules are `active` because projects use them today, but none has been tested
  against a model. Each has `review_by: 2026-12-31`, so the first audit finds them.
- The registry copies R43's text without its pronoun ("a step to perform").
