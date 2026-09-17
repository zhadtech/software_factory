---
name: requirements-elicitation
description: Turn prose, intent or a vague request into numbered, testable requirements and user stories with Given/When/Then acceptance criteria. Use when requirements are missing, ambiguous or conflicting, when writing a BRD/SRS, when a story needs acceptance criteria, or before design starts.
---

# Requirements Elicitation & Specification

## Procedure

1. **Harvest** — read every existing source: intake notes, tickets, emails, current system
   behaviour, regulatory text. Cite the source on each requirement you derive.
2. **Separate** problem from solution. Move solution language into a "proposed approach — architect
   to decide" note; keep requirements free of implementation.
3. **Decompose** compound statements. One "and", "or", "if" in a requirement usually hides two.
4. **Hunt ambiguity** with the weasel-word list below. Each hit is either pinned to a number or
   becomes a numbered open question.
5. **Specify** requirements, then stories, then rules, then data elements.
6. **Prioritise** with MoSCoW, and record who set the priority.
7. **Publish** the open-question list, marking each blocking or non-blocking.

## Weasel words — every one is a defect until defined

`fast` · `slow` · `scalable` · `secure` · `user-friendly` · `intuitive` · `robust` · `flexible`
`appropriate` · `reasonable` · `sufficient` · `as needed` · `etc.` · `and/or` · `support`
`handle` · `process` · `manage` · `optimise` · `real-time` · `seamless` · `minimal` · `several`

Replace with a number, a named standard, or an open question. Never with a plausible guess.

## Requirement template

```markdown
### REQ-0042 — Admin console requires MFA
- **Statement:** The system shall require a second authentication factor for every session
  that accesses the admin console.
- **Rationale:** Admin sessions can alter customer records; single-factor access is the
  primary account-takeover path.
- **Source:** Security policy §4.2 / stakeholder: Head of Ops, 2026-09-10
- **Priority:** Must
- **Acceptance:** verified by TC-0101, TC-0102
- **Traces to:** US-0107, NFR-0009, CTL-AC-02
- **Open questions:** Q7 (which factors are permitted?)
```

## User story template

```markdown
### US-0107 — Admin enrols a second factor
**As an** administrator **I want** to enrol an authenticator app
**so that** my account cannot be taken over with a stolen password.

**Acceptance criteria**
- Given an admin with no enrolled factor, when they sign in, then they are required to enrol
  before reaching any admin page.
- Given an enrolled admin, when they enter a valid code, then the session is established.
- Given an enrolled admin, when they enter an invalid code 5 times within 10 minutes, then the
  account is locked for 15 minutes and a security event is logged.
- Given an enrolled admin, when their code is expired, then the error states that the code
  expired and offers a retry.

**Out of scope:** SMS as a factor (see Q7). **Traces to:** REQ-0042.
```

## Quality checklist (INVEST + testability)

- [ ] Independent, Negotiable, Valuable, Estimable, Small, Testable
- [ ] Single assertion per requirement
- [ ] Negative, boundary and permission cases present in acceptance criteria
- [ ] A tester could execute every criterion without asking the author a question
- [ ] Personal-data elements flagged for classification
- [ ] Every term of art in the glossary, used consistently
- [ ] Priority set, with the person who set it named
- [ ] Open questions numbered and marked blocking / non-blocking

## The one rule

**A gap is an output.** Never close an unknown with an invention — a fabricated requirement
propagates silently into design, code, tests and controls, and is discovered only in production.
