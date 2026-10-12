# Waiting on Zhad

1. How should `main` be protected, so only Zhad merges? GitHub refuses branch protection on this
   private repo without GitHub Pro (checked 2026-10-13). Options: pay for Pro; make the repo public;
   or add a hook to this repo that blocks any agent push to `main`. Recommended: the hook, which is
   free and works now; buy Pro later if a second person joins. Blocks: "agents propose, Zhad merges"
   is only a written rule until then.
2. Archive `zhadtech/agi-standards` and `zhadtech/list-agents` on GitHub, so they are read-only?
   Recommended: yes. Blocks: nothing yet.
3. What is the monthly ceiling for eval spending? Recommended: start small, about the cost of one
   long session, and raise it with evidence. Blocks: phase 2 evals.
4. Add a `supersedes` row to the registry field table in `CHARTER.md`? Only Zhad edits the charter.
   Recommended: yes, meaning "the rules this one replaces once it moves to trial or active".
   Blocks: nothing; the field already works.
5. The charter lets agents open version-bump pull requests in projects, and phase 4 plans a routine
   for it. That conflicts with "the factory never changes another project". Should projects pull
   updates themselves instead? Recommended: yes. Plugins update through Claude Code's plugin
   auto-update when their version changes, and a project refreshes its rules block by running a
   factory script from inside the project. Remove that charter row. Blocks: phase 4.
