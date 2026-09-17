# SDLC Agent Team

Thirteen role-specialised Claude Code subagents plus a sixteen-skill shared library, covering a
regulated software development lifecycle from intake to operations.

Stack-agnostic: every engineering role detects the target repository's language, framework, test
runner and conventions before acting, rather than imposing a house stack.

## What's here

```
.claude/
├── agents/       13 role definitions  — who does what, what they own, what they refuse to do
├── skills/       16 reusable methods  — how the work is actually done, with templates
└── handbook/     shared governance, travels with the agents
    ├── TEAM-CHARTER.md   the roster, operating principles, how to run the team
    ├── WORKFLOW.md       G0–G6 phase gates, handoff graph, handoff protocol, severity scale
    ├── RACI.md           one accountable role per activity — the tie-breaker
    └── ARTIFACTS.md      canonical paths, ID scheme, front matter, writing rules
install.sh        install into a target project (copy or symlink)
```

`.claude/handbook/` is the *team's* reference. `docs/sdlc/` is where the team *writes* — inside
whichever project you point it at.

## The roster

| Agent | Owns |
|---|---|
| `project-manager` | Charter, plan, RAID log, gate reviews, go/no-go |
| `business-analyst` | BRD, SRS, user stories, acceptance criteria, glossary |
| `solution-architect` | Solution design, ADRs, NFR budgets |
| `ux-designer` | User flows, wireframes, all screen states, WCAG 2.2 AA |
| `data-engineer` | Data model, migrations, classification, retention, pipelines |
| `software-engineer` | Implementation, unit tests, PR hygiene |
| `code-reviewer` | Merge gate — correctness, security, tests, maintainability |
| `qa-lead` | Test strategy, risk-based coverage, quality gates |
| `automation-tester` | Automated suites, CI wiring, flake policy |
| `performance-engineer` | Load modelling, profiling, capacity, SLO validation |
| `security-officer` | Threat model, control matrix, findings, audit evidence, gate veto |
| `devops-engineer` | CI/CD, IaC, environments, release, rollback, observability |
| `technical-writer` | User docs, API reference, runbooks, release notes |

## The skills

`requirements-elicitation` · `traceability-matrix` · `architecture-decision-record` ·
`threat-modeling` · `compliance-control-mapping` · `test-strategy` · `test-automation-design` ·
`secure-code-review` · `ci-cd-and-release` · `observability-and-slo` · `performance-testing` ·
`data-modeling-and-privacy` · `ux-flows-and-accessibility` · `technical-documentation` ·
`phase-gate-review` · `sprint-and-raid-management`

Agents invoke these; you can also invoke one directly with `/skill-name`.

## Install into a project

```bash
/path/to/list-agents/install.sh /path/to/your/project
```

Copies `.claude/agents/`, `.claude/skills/` and `.claude/handbook/` into the target repo (existing files are backed up).
Pass `--link` to symlink instead, so every project tracks edits made here.

To make the team available in **every** project on this machine instead:

```bash
SRC=/path/to/list-agents/.claude
mkdir -p ~/.claude/agents ~/.claude/skills
cp -R "$SRC"/agents/* ~/.claude/agents/
cp -R "$SRC"/skills/* ~/.claude/skills/
cp -R "$SRC"/handbook ~/.claude/handbook
```

## Use

Invoke a single role:

```bash
claude "use the business-analyst agent to turn docs/intake.md into an SRS with acceptance criteria"
```

Run a phase with the PM coordinating:

```bash
claude "use the project-manager agent to run the G1 requirements gate for the checkout redesign"
```

A typical feature, in order:

```
business-analyst   → requirements + stories with acceptance criteria
solution-architect → design, ADRs, NFR budgets     ─┐
ux-designer        → flows, states, a11y            ├─ G2, security-officer threat-models here
security-officer   → threat model, controls        ─┘
data-engineer      → schema + migration plan
software-engineer  → implementation + unit tests
code-reviewer      → merge gate                     ← different role from the author, always
automation-tester  → suites wired into CI
qa-lead            → execution, coverage verdict    ─┐
performance-engineer → NFR validation                ├─ G4
security-officer   → security sign-off             ─┘
devops-engineer    → change record, release, rollback, observability  ← G5
technical-writer   → docs, runbooks, release notes
project-manager    → gate records throughout, go/no-go at G5
```

## Design decisions worth knowing

- **Artifacts, not chat.** Conclusions land in files under `docs/sdlc/` with immutable IDs. If it
  isn't written down with an ID, it didn't happen.
- **Separation of duties is enforced in the prompts.** The Code Reviewer cannot edit the code it
  reviews; the Security Officer cannot fix its own findings; the author never approves their own
  work. This is what makes the audit trail real rather than decorative.
- **Every agent has a "never invent" guardrail.** A missing requirement, an unknown NFR target, an
  unmeasured performance number and an unverified control are all *outputs* — open questions and
  RAID entries — never gaps quietly filled with something plausible.
- **Verification over assertion.** Agents that can run tests, migrations or commands must run them
  and show real output. "Tests pass" without output is not accepted by the receiving role.
- **Models:** `solution-architect`, `security-officer`, `business-analyst` and `code-reviewer` run
  on Opus (judgement-heavy, expensive to get wrong); `technical-writer` on Sonnet; the rest inherit
  the session model. Change the `model:` line in any agent file to adjust.

## Tuning

- **Less ceremony:** delete the "Regulated-mode duties" section from the agents and drop the
  `phase-gate-review` and `compliance-control-mapping` skills. The rest works unchanged.
- **A specific stack:** add the stack's tooling defaults to `software-engineer`, `automation-tester`
  and `devops-engineer` under Core skills.
- **Your compliance regime:** replace the example framework IDs in `compliance-control-mapping`
  with your actual framework's clause IDs.
- **Ownership disputes:** `.claude/handbook/RACI.md` is the tie-breaker. Edit it, not the agents,
  when you want to move an accountability.
