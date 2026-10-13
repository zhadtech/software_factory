# software_factory

A development process for coding agents, shipped as Claude Code plugins and a project template.
The director decides what becomes a rule; agents propose. `CHARTER.md` says who decides what.

## What is here

| Path | What it is |
|---|---|
| `plugins/sdlc-core/` | Hooks that keep sessions cheap and resumable and keep role work with the roles: a state card at start, size budgets, a queue check, a handoff check |
| `plugins/sdlc-lean/` | The five-role lean team: product, architect, builder, reviewer, release |
| `plugins/sdlc-stacks/` | Stack rules, added the first time Claude touches a file they cover. Each stack is identified by marker files, so one project can mix stacks |
| `templates/project/` | Starting files for a project: rules, settings, budgets, queue, progress files, quiet verify |
| `registry/` | Every rule with its source and status, the stacks, and the pool of candidate tips |
| `intel/` | The weekly scout: its instructions, sources, inbox and digest |
| `audits/`, `metrics/` | The monthly audit's instructions and reports, and the factory's measures over time |
| `evals/` | Eval cases, the monthly eval budget, and a ledger of every run |
| `scripts/` | The factory's checks and tools |

## Start a project

```bash
bash scripts/new-project.sh ~/my-project
```

This copies the template into a new folder, makes it a git repo on `main`, and commits the
starting files. Open the folder in Claude Code and trust it. Claude Code then fetches the
factory's marketplace in the background and turns on the three plugins that `.claude/settings.json`
names. If they are missing in that first session, run `/reload-plugins`. Each person needs read
access to this repo on GitHub.

Start each request for the role agents with `/sdlc-lean:team`, for example
`/sdlc-lean:team Add a word counter with tests`. Claude Code starts sub-agents only when you ask,
and this command is how you ask. Product writes the steps, the builder builds them, and the
reviewer checks the medium and large ones.

The template's verify script checks size budgets only. Add the project's own stages, such as
tests and type checks, to `scripts/verify.sh`.

## Try a plugin change before it reaches `main`

Projects install plugins from this repo's `main` branch. To try a change from a work branch,
check out that branch here, make a throwaway project, and load the plugins from this folder:

```bash
bash scripts/new-project.sh ~/trial-project
```

```bash
cd ~/trial-project && claude --plugin-dir ~/path/to/software_factory/plugins
```

`--plugin-dir` pointed at `plugins/` loads every plugin in it, for that session only. These local
copies replace any installed copies with the same names.

## The weekly scout

Each Monday the scout reads the Claude Code changelog, the Claude platform release notes and the
other sources in `intel/sources.yaml`. It writes what matters to `intel/inbox/<date>.md`, adds a
section to `intel/digest.md`, and opens a draft pull request with any changes it proposes.
Pin `intel/digest.md` on GitHub to read the latest week. To run it by hand, start Claude Code in
this repo and say: "Follow intel/scout.md."

## Keep a project up to date

The factory's plugins update themselves, because the template turns on auto-update for its
marketplace. Rules in a project's `AGENTS.md` do not: run `sdlc-update` in the project to pull them,
review `git diff AGENTS.md`, and commit. It also lists, without changing them, the template files
where the project differs from the factory's. `sdlc-metrics` reports how the project's process is
doing, from its own commits and progress files.

## Audits and metrics

On the first Monday of each month the auditor follows `audits/auditor.md`: it runs
`scripts/audit.rb` and `scripts/metrics.sh --record`, writes `audits/<date>.md` with proposals, and
opens a draft pull request. It proposes; the director decides every rule's status.

## Evals

An eval runs a small task headless, three times with a plugin and three times without it, and
checks the result. That difference is the evidence a rule needs to become active, and the ablation a
deprecation needs (`CHARTER.md`). `scripts/eval.sh` records every run's pass and cost in
`evals/ledger.csv` and stops before the month passes the ceiling in `evals/budget.json`.

## Change the factory

Agents working here follow `AGENTS.md`. Run every check before each commit:

```bash
bash scripts/test.sh
```
