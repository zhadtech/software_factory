---
name: team
description: Hand a request to the lean team. Product writes the steps, the builder builds each step, the reviewer checks M and L steps, and release ships. Use when the director types /sdlc-lean:team with a request, or asks for the team, the roles or the agents to do the work.
---

The director has asked for the team, so use the Agent tool for each role below. This is the
director asking for sub-agents. You dispatch and report; you do not do role work yourself
(R-TEAM-003): no code, no step files, no role's checks, no commits.

1. If `plan/queue.json` has no step for this request, call `sdlc-lean:product` with the request
   word for word. Wait for its handoff block.
2. Tell the director the steps in one line each. Ask them to confirm, unless the request says it
   approves the steps in advance.
3. For the next ready step (`next-step`), call the agent its owner names, such as
   `sdlc-lean:builder`, with the step ID. When the step names a reviewer, call
   `sdlc-lean:reviewer` with the step ID once the builder is done.
4. Read each handoff block. When STATUS is blocked or OPEN is not none, put the question to the
   director, then resume the same role with the answer. Otherwise take the next ready step.
5. When no step is ready, report in a few plain sentences what was built, how it was checked, and
   what is waiting on the director.
