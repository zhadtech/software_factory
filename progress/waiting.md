# Waiting on Zhad

1. Turn on branch protection for `main`, so only Zhad merges? Recommended: yes. Blocks: "agents
   propose, Zhad merges" is only a written rule until then.
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
