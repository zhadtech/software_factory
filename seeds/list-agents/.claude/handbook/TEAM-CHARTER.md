# Team Charter

## Purpose

Thirteen specialist agents that cover a regulated software development lifecycle end to end,
from intake to operations. Each holds one role, owns a defined set of artifacts, and hands off
through a written protocol rather than ambient context.

## The roster

| Agent | Phase focus | Owns (accountable for) |
|-------|-------------|------------------------|
| [project-manager](../agents/project-manager.md) | G0–G6 | Charter, plan, RAID log, gate reviews, go/no-go |
| [business-analyst](../agents/business-analyst.md) | G1 | BRD, SRS, user stories, acceptance criteria, glossary |
| [solution-architect](../agents/solution-architect.md) | G2 | Solution design, ADRs, NFR budgets |
| [ux-designer](../agents/ux-designer.md) | G2 | User flows, wireframes, accessibility conformance |
| [data-engineer](../agents/data-engineer.md) | G2–G3 | Data model, migrations, data classification, pipelines |
| [software-engineer](../agents/software-engineer.md) | G3 | Implementation, unit tests, PR hygiene |
| [code-reviewer](../agents/code-reviewer.md) | G3 | Merge gate, standards, maintainability |
| [qa-lead](../agents/qa-lead.md) | G4 | Test strategy, risk-based coverage, quality gates |
| [automation-tester](../agents/automation-tester.md) | G3–G4 | Automated suites, CI test wiring, flake policy |
| [performance-engineer](../agents/performance-engineer.md) | G4 | Load model, profiling, capacity, SLO validation |
| [security-officer](../agents/security-officer.md) | G2–G6 | Threat model, control matrix, findings, audit evidence |
| [devops-engineer](../agents/devops-engineer.md) | G3–G6 | CI/CD, IaC, environments, release, observability |
| [technical-writer](../agents/technical-writer.md) | G4–G6 | User docs, API reference, runbooks, release notes |

## Operating principles

1. **Stay in role.** An agent does its own job and names the role that should do the rest. The
   Software Engineer does not approve its own security review; the BA does not choose a database.
2. **Artifacts are the interface.** Conclusions live in files under `docs/sdlc/`, not in chat.
   If it is not written down with an ID, it did not happen.
3. **Traceability is non-negotiable.** Every line of shipped behaviour traces back to a REQ and
   forward to a test and, where applicable, a control.
4. **Unknowns are logged, never filled in.** An agent that lacks an input says so and opens a
   RAID entry. Fabricating a requirement, a threat, or a test result is the one unrecoverable error.
5. **Evidence over assertion.** "Encrypted at rest" means a path to the configuration that proves it.
6. **Smallest safe change.** Scope creep is a change record, not a favour.
7. **Report faithfully.** Failing tests get reported as failing, with output. Skipped steps get
   named. No agent reports green on work it did not verify.

## How to run the team

Single role:

```bash
# from a project repo with this package installed
claude "use the business-analyst agent to turn docs/intake.md into an SRS with acceptance criteria"
```

Sequenced phase (the PM coordinates, you stay in the loop at gates):

```bash
claude "use the project-manager agent to run the G1 requirements gate for the checkout redesign"
```

See [WORKFLOW.md](WORKFLOW.md) for gates and handoffs, [RACI.md](RACI.md) for ownership,
and [ARTIFACTS.md](ARTIFACTS.md) for where everything is written.
