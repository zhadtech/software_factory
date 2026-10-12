# Waiting on Zhad

1. Should the 11 proposed rules go to trial in fog_of_war? They replace the 11 rules that name
   PLAN.md or PROGRESS.md, so the template can use the state card, the step queue and the small
   progress files. Recommended: yes, all 11. Blocks: question 2.
2. May an agent install sdlc-core and the template into fog_of_war, on a new branch in that repo,
   together with the audit's day-one changes? Recommended: yes. Blocks: finishing phase 1.
3. Create the private GitHub repo `zhadtech/software_factory` and push `phase-1` as `main`?
   Recommended: yes. Blocks: installing the plugin from GitHub, branch protection, pull requests.
4. Turn on branch protection for `main`, so only Zhad merges? Recommended: yes, right after the
   first push. Blocks: "agents propose, Zhad merges" is only a written rule until then.
5. Archive `zhadtech/agi-standards` and `zhadtech/list-agents` on GitHub, so they are read-only?
   Recommended: yes, after question 3. Blocks: nothing yet.
6. What is the monthly ceiling for eval spending? Recommended: start small, about the cost of one
   long session, and raise it with evidence. Blocks: phase 2 evals.
7. Add a `supersedes` row to the registry field table in `CHARTER.md`? Only Zhad edits the charter.
   Recommended: yes, with the meaning "the rules this one replaces once it moves to trial or
   active". Blocks: nothing; the field already works.
