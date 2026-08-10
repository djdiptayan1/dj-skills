---
name: testing-suite
description: Multi-agent code review and approval-gated implementation, grounded in Clean Code & The Clean Coder.
---

# Testing Suite

A portable multi-agent framework for **read-only code review** and **approval-gated implementation**.
Nine reviewers examine a change from independent angles; an Orchestrator synthesizes one verdict;
exactly one agent may write, and only after you say YES.

## Two flows

**`/code-review` — 9 agents, read-only.** For uncommitted work, a PR, a branch diff, a commit, or
named files. Runs TestRunner, LinterStaticAnalysis, CodeReviewer, SecurityReviewer,
QualityStyleReviewer, TestQualityReviewer, PerformanceReviewer, DependencyDeploymentReviewer, and
SimplificationMaintainabilityReviewer — then `Orchestrator` synthesizes findings into a merge verdict.
Never edits files.

**`/apply-approved-suite` — 6 agents, write-gated.** Only after review findings are approved:

```
DatabaseAuditor -> Tester -> Critic -> Orchestrator [APPROVAL GATE] -> TechLead -> Validator
```

`Orchestrator` presents the brief and **stops** for an explicit YES. `TechLead` is the only
write-authorized agent and implements only what was approved. `Validator` re-runs tests afterward.

> **Sequencing lives in the playbooks, not in the agents.** No agent spawns another; `Orchestrator`
> spawns `TechLead` and only after approval. This is what makes the gate a structural property
> rather than a promise in a prompt.

## Agents

**Read-only reviewers**
| Agent | Reviews for |
|---|---|
| `agents/test-runner.md` | Test results, duration, and E1/E2 one-step build & test |
| `agents/linter-static-analysis.md` | Lint, typecheck, and LSP diagnostics |
| `agents/code-reviewer.md` | Naming, function size & abstraction, arguments, CQS, Law of Demeter (gated on objects vs. data structures), null hygiene, SRP |
| `agents/security-reviewer.md` | Injection, authz, secrets, prompt boundaries, leaky error handling |
| `agents/quality-style-reviewer.md` | Duplication, comments (C1–C5), dead code, clutter, consistency |
| `agents/test-quality-reviewer.md` | F.I.R.S.T., single concept, sufficiency (T1–T9), Test Automation Pyramid placement |
| `agents/performance-reviewer.md` | N+1s, blocking work, render churn, leaks, unbounded loads |
| `agents/dependency-deployment-reviewer.md` | Dependencies, boundary wrapping & learning tests, migrations, rollout, observability |
| `agents/simplification-maintainability-reviewer.md` | Beck's Four Rules of Simple Design, YAGNI, scope atomicity |

**Implementation flow**
| Agent | Writes? | Role |
|---|---|---|
| `agents/database-auditor.md` | no | Locates the relevant contract surface (schema, API, UI typings) and audits conformance |
| `agents/tester.md` | no | Detects the active runner and designs non-flaky tests, including checkpoint regressions |
| `agents/critic.md` | no | Four-tier peer review (SDE 1 → SDE 2 → Senior → Head of Eng). Verifies, vetoes, consolidates |
| `agents/orchestrator.md` | no | Synthesis and the approval gate. The only agent that may spawn `TechLead` |
| `agents/tech-lead.md` | **yes** | The only write-authorized agent. Implements the approved brief |
| `agents/validator.md` | no | Re-runs tests, checks coverage, false coverage, and flakiness |

## Playbooks
- **Review My Code** — `skill://testing-suite/playbooks/code-review.md` (`/code-review`)
- **Apply Approved Fixes** — `skill://testing-suite/playbooks/apply-approved-suite.md` (`/apply-approved-suite`)

## Project checkpoints — read this before sharing the suite

The agents ship **general craft**; your repository ships **its own scar tissue**. Copy
`project-checkpoints.example.md` into the root of the repo you want reviewed, as
`project-checkpoints.md`, and fill it with the bugs that already bit you: ownership chains,
error-handling contracts, framework gotchas, flow-consistency rules.

Every agent reads `project-checkpoints.md`, `AGENTS.md`, `CLAUDE.md`, and `.cursorrules` at runtime.
**Project conventions override generic book heuristics wherever they conflict.**

Never hardcode domain specifics into an agent prompt — that is what makes the suite non-portable.

## Model & reasoning routing

**Each agent's `model` and `thinkingLevel` frontmatter is the single source of truth.** Runtimes that
support per-agent overrides should read it from there. This file does not restate model names.

**Reasoning tiers**, by the cost of being wrong:
- `low` — mechanical checks with a verifiable output: TestRunner, LinterStaticAnalysis.
- `medium` — judgement over a bounded diff: CodeReviewer, QualityStyleReviewer, TestQualityReviewer, PerformanceReviewer, SimplificationMaintainabilityReviewer, Tester.
- `high` — where a wrong call ships a defect or a bad write: SecurityReviewer, DependencyDeploymentReviewer, DatabaseAuditor, Critic, Orchestrator, TechLead, Validator.

**Escalation policy.** Start at the tier above. Escalate the model or reasoning level when the change
touches **auth, money, migrations, data integrity, public APIs, or production rollout** — or when
tests fail, an agent reports uncertainty, or two agents' findings conflict. Do not escalate for
volume alone.

## Grounding

Principles are drawn from *Clean Code* (Martin, 2008) and *The Clean Coder* (Martin, 2011), applied
with their own qualifiers intact:
- The **Law of Demeter** does not apply to data structures — only to objects that hide data behind behaviour.
- The **Test Automation Pyramid** has five tiers (Unit, Component, Integration, System, Manual Exploratory) and its numbers are *coverage of the system*, not shares of test count.
- **Single Concept per Test** ranks above "one assert per test" — multiple asserts verifying one concept are correct.
- The **Three Laws of TDD** govern write order, which a finished diff cannot show; reviewers check sufficiency and timeliness instead.
- These heuristics are a school of thought, not laws. Findings must show a real cost to reading or changing the code.

## How to run
1. Read the playbook for the flow you want; it resolves `$TARGET_SCOPE` and `$CONFINEMENT_POLICY`.
2. Pass both, plus any project-context file paths, to every agent.
3. `/code-review`: run the 9 reviewers in parallel where supported, then `Orchestrator`.
4. `/apply-approved-suite`: run the 6 agents in the documented order. Do not skip the gate at step 4.
