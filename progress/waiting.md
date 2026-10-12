# Waiting on Zhad

1. May agents push work branches and open draft pull requests in this repo without asking each
   time? The charter already allows draft pull requests, but rule F1 in `AGENTS.md` still asks for a
   yes on every push. The new hook blocks pushes to `main` and merges either way, so you still decide
   what lands. Recommended: yes, branches and draft pull requests only. Blocks: every change reaching
   GitHub without a round trip to you.
