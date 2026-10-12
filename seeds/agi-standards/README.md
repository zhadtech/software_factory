# Agent standards

A copy-paste kit that makes a coding agent resumable across sessions without
re-reading the codebase every time.

The problem it solves: a session hits a limit and dies; the next agent starts cold,
re-explores the repo to rebuild context, and burns a large fraction of its budget
rediscovering things the previous session already knew. A progress file alone doesn't
fix this, because a progress file records *what happened* rather than *what to do next*
— so the new agent still explores.

The fix is four files with strictly separated jobs, and a protocol that keeps them true.

## Install

```bash
./install.sh /path/to/new/project
```

Then fill in section 8 of `AGENTS.md` (the project's commands). That's the five minutes
with the highest return in the whole kit.

## The files

| File | Job | Loaded |
|---|---|---|
| `AGENTS.md` | rules and behavior — never facts about current work | every session, automatically |
| `CLAUDE.md` | one-line pointer at `AGENTS.md` so you maintain one file | every session |
| `INDEX.md` | path → what it is → **when to open it** | on demand, one row at a time |
| `PLAN.md` | current task as verifiable steps with checkboxes | at boot |
| `PROGRESS.md` | `NEXT ACTION`, dead ends, decisions, append-only log | at boot, top block only |

The split matters. Rules are stable and belong in the cached prefix. Repo structure is
semi-stable and should be looked up, not memorized. Task state is volatile and gets
rewritten constantly. Mixing them means every task update re-bills your rules.

## The loop

**Boot** → `AGENTS.md` → `PROGRESS.md` NEXT ACTION → `PLAN.md` first unchecked step →
`INDEX.md` rows for the files that step touches. Then start working. No exploration.

**Per step** → do it → run its verification → tick the `PLAN.md` box and append the
`PROGRESS.md` entry *in the same turn* → next step.

**At ~60% context** → finish the current step, rewrite `NEXT ACTION`, stop.

## Why it survives a hard cutoff

- `NEXT ACTION` sits at the top of `PROGRESS.md` and is literal enough to act on cold.
- Every entry carries `file:line` anchors and the exact verify command, so nothing is re-derived.
- **Dead ends are recorded with reasons** — the next agent skips the failures instead of
  repeating them. This is where most of the savings actually come from.
- Bookkeeping happens per step, so an abrupt death loses at most one step of state.
- `INDEX.md`'s "open it when" column turns search into lookup.

## Files

- [AGENTS.md](AGENTS.md) — the standards file. 40 numbered rules, ~120 lines.
- [PLAYBOOK.md](PLAYBOOK.md) — 145 collected tips from practitioners, with sources. Reference, not context. Promote rules from here into `AGENTS.md` when you get bitten.
- [templates/](templates/) — blank `INDEX.md`, `PLAN.md`, `PROGRESS.md`.
- [install.sh](install.sh) — copies the kit into a project, never overwrites.

## Maintaining it

Add a rule when an agent gets the same thing wrong twice. Delete one that never fires.
Anything that must hold every single time belongs in a hook, a lint rule, or CI — not
in a prompt. A 400-line rulebook is followed worse than a 120-line one.
# Agent standards

A copy-paste kit that makes a coding agent resumable across sessions without
re-reading the codebase every time.

The problem it solves: a session hits a limit and dies; the next agent starts cold,
re-explores the repo to rebuild context, and burns a large fraction of its budget
rediscovering things the previous session already knew. A progress file alone doesn't
fix this, because a progress file records *what happened* rather than *what to do next*
— so the new agent still explores.

The fix is four files with strictly separated jobs, and a protocol that keeps them true.

## Install

```bash
./install.sh /path/to/new/project
```

Then fill in section 8 of `AGENTS.md` (the project's commands). That's the five minutes
with the highest return in the whole kit.

## The files

| File | Job | Loaded |
|---|---|---|
| `AGENTS.md` | rules and behavior — never facts about current work | every session, automatically |
| `CLAUDE.md` | one-line pointer at `AGENTS.md` so you maintain one file | every session |
| `INDEX.md` | path → what it is → **when to open it** | on demand, one row at a time |
| `PLAN.md` | current task as verifiable steps with checkboxes | at boot |
| `PROGRESS.md` | `NEXT ACTION`, dead ends, decisions, append-only log | at boot, top block only |

The split matters. Rules are stable and belong in the cached prefix. Repo structure is
semi-stable and should be looked up, not memorized. Task state is volatile and gets
rewritten constantly. Mixing them means every task update re-bills your rules.

## The loop

**Boot** → `AGENTS.md` → `PROGRESS.md` NEXT ACTION → `PLAN.md` first unchecked step →
`INDEX.md` rows for the files that step touches. Then start working. No exploration.

**Per step** → do it → run its verification → tick the `PLAN.md` box and append the
`PROGRESS.md` entry *in the same turn* → next step.

**At ~60% context** → finish the current step, rewrite `NEXT ACTION`, stop.

## Why it survives a hard cutoff

- `NEXT ACTION` sits at the top of `PROGRESS.md` and is literal enough to act on cold.
- Every entry carries `file:line` anchors and the exact verify command, so nothing is re-derived.
- **Dead ends are recorded with reasons** — the next agent skips the failures instead of
  repeating them. This is where most of the savings actually come from.
- Bookkeeping happens per step, so an abrupt death loses at most one step of state.
- `INDEX.md`'s "open it when" column turns search into lookup.

## Files

- [AGENTS.md](AGENTS.md) — the standards file. 40 numbered rules, ~120 lines.
- [PLAYBOOK.md](PLAYBOOK.md) — 145 collected tips from practitioners, with sources. Reference, not context. Promote rules from here into `AGENTS.md` when you get bitten.
- [templates/](templates/) — blank `INDEX.md`, `PLAN.md`, `PROGRESS.md`.
- [install.sh](install.sh) — copies the kit into a project, never overwrites.

## Maintaining it

Add a rule when an agent gets the same thing wrong twice. Delete one that never fires.
Anything that must hold every single time belongs in a hook, a lint rule, or CI — not
in a prompt. A 400-line rulebook is followed worse than a 120-line one.

---

## FAQ

### How do I use Section 8 of AGENTS.md?

R1–R40 are portable — identical in every repo you drop this kit into. Section 8 is the
seam where the project plugs in, and it ships blank on purpose.

Its job is to kill a discovery loop that otherwise runs *every single session*: the agent
tries `npm test`, gets an error, opens `package.json`, tries again, greps for the test
directory. Four to six tool calls before any work starts, repeated on every resume.

Filled in for a Vue 2 + vue-cli-service project:

```markdown
## 8. Project specifics

- **Stack:** Vue 2 + TypeScript, vue-cli-service, Jest (unit), Cypress (e2e), SCSS
- **Install:** `npm ci`
- **Run:** `npm run serve`
- **Test (all):** `npm run test:unit`
- **Test (one file):** `npm run test:unit -- src/components/Foo.spec.ts`
- **Lint:** `npm run lint`
- **Typecheck:** none wired — `lint` is stylelint + eclint only, it will NOT catch TS errors
- **Do not touch:** `dist/`, `package-lock.json` (regenerate via npm, don't hand-edit)
- **Known sharp edges:**
  - `npm test` runs unit **and** Cypress e2e. Never use it as a step verification — use `test:unit`.
  - DI is `inversify-props`; services register at boot. Adding one without registering
    fails at runtime, not compile time.
```

Three things about what earns a line here:

**"Test (one file)" is the highest-value line, and it is not in `package.json`.** You derive
the `-- <path>` passthrough once. The agent runs single-file tests dozens of times per
session; the full suite is slow and dumps output you pay for on every turn afterward.

**"Known sharp edges" is where the real savings are.** `npm test` quietly booting Cypress is
exactly the kind of thing an agent discovers by burning two minutes and a wall of output —
once per session, forever, until someone writes it down.

**A missing tool is worth a line.** "no typecheck wired" stops the agent from claiming type
safety it never verified. A project with no test script at all should say so explicitly and
name what to use instead (`verify with npm run build`), because blank leaves the agent
inventing a command.

**How to fill it:** let the agent draft it from the manifest, then run every command
yourself before committing. A wrong command in Section 8 is worse than a blank one — blank
makes the agent look, wrong makes it trust.

### How do I promote a rule from PLAYBOOK.md into AGENTS.md?

**The trigger is evidence, not agreement.** An agent did the same wrong thing twice. Not
"this playbook item sounds sensible." Promoting on enthusiasm puts you at 400 lines within a
month, back to rules being ignored.

**First route it — most playbook items are not rules:**

| What you observed | Where it actually goes |
|---|---|
| Agent misbehaves in a way it could have chosen differently | `AGENTS.md` rule |
| Agent didn't know a project fact or command | `AGENTS.md` §8 |
| Agent couldn't find where something lives | `INDEX.md` row |
| Must hold 100% of the time, no judgment involved | hook / lint rule / CI (R40) |
| True only for the current task | `PROGRESS.md` |

Playbook #73 ("point at where shared helpers live") reads like a rule but is an INDEX row.
#116 ("format on write") is a hook. Promoting either into `AGENTS.md` spends a line on
something a tool should enforce deterministically.

**Then the mechanics:**

1. Find the playbook item; keep its number as provenance.
2. Rewrite it as an imperative with the alternative attached — playbook prose is not rule
   voice. #82's list of banned reflexes becomes:

   ```markdown
   **R41.** Never silence a type error with `any` or `@ts-expect-error`; fix the type or ask.
   ```
3. Put it in the section it belongs to (that one goes under §4 Writing code).
4. **Give it the next free number — R41 — even though it sits between R25 and R26.**
   Numbers are stable IDs, not positions. Never renumber to keep them sequential: it breaks
   every citation in your PROGRESS logs and turns a one-line change into a whole-file diff.
5. Delete the playbook line, or leave it. It's a pool; duplication there is harmless.

**The line budget forces a swap, not an add.** `AGENTS.md` is ~120 lines against a ~150
ceiling. After roughly a dozen promotions you are out of room, and that is the mechanism
working as intended. Read the file quarterly and ask which rules you have never once seen
violated — those are things the model already does by default, and they are crowding out the
rules that aren't.

### Is promotion automatic?

**No. It is entirely manual. Nothing in this kit does it for you.**

Two reasons not to automate the decision:

**The evidence spans sessions, but agents don't.** "Got the same thing wrong twice" is a
pattern across session 1 and session 7. The agent in session 7 has no memory of session 1 —
that is the entire premise of this kit. It cannot detect its own repeat offenses.

**A self-editing constitution drifts the wrong way.** An agent able to rewrite `AGENTS.md`
will rationalize the rule it just violated, and will add far more than it deletes. You reach
the 400-line rot problem faster, not slower. R13 also applies: editing that file mid-session
re-bills the cached prompt prefix.

What *is* worth automating is the evidence collection. As shipped, `PROGRESS.md` has Dead
ends and Decisions but nothing capturing "the user corrected me on this" — so at review time
you are doing archaeology through transcripts, which is the exact cost this kit exists to
avoid.

**Not shipped in `templates/PROGRESS.md` yet — add it if you want this:**

```markdown
## 🔁 Rule candidates
| Date | I was corrected on | Playbook # |
|---|---|---|
| 2026-09-06 | ran `npm test`, booted Cypress, user stopped me | #58, §8 |
```

An agent can observe corrections reliably *within* a session, so it appends rows as it goes.
Promotion then becomes: skim accumulated rows across projects, promote anything that appears
twice. Five minutes, quarterly, against real evidence instead of recall.

**Agent gathers, you decide, you edit.**

### When a new decision is required from the user and is placed in open question section, where is the best place to answer them?

**In a new prompt**