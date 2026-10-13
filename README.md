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
| `scripts/` | The factory's checks and tools |

## Start a project

```bash
bash scripts/new-project.sh ~/my-project
```

This copies the template into a new folder, makes it a git repo on `main`, and commits the
starting files. Open the folder in Claude Code and trust it. Claude Code then fetches the
factory's marketplace in the background and turns on the two plugins that `.claude/settings.json`
names. If they are missing in that first session, run `/reload-plugins`. Each person needs read
access to this repo on GitHub.

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

## Change the factory

Agents working here follow `AGENTS.md`. Run every check before each commit:

```bash
bash scripts/test.sh
```
