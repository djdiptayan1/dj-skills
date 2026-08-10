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

**15 agent files: 9 read-only reviewers and 6 in the implementation flow.** `Orchestrator` runs in
both flows but is counted once, under implementation. `/code-review` therefore invokes 10 agents —
the 9 reviewers plus `Orchestrator` for synthesis.

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

The agents ship **general craft**; your repository ships **its own scar tissue**. All 15 agents read
`project-checkpoints.md`, `AGENTS.md`, `CLAUDE.md`, and `.cursorrules` at runtime.
**Project conventions override generic book heuristics wherever they conflict.**

Never hardcode domain specifics into an agent prompt — that is what makes the suite non-portable.

### Setting it up in a target repo — agent-executable procedure

Any agent asked to "set up project checkpoints" runs these five steps in order, from the root of the
repository being reviewed.

**1. Copy the template.** Use whichever path resolves in this runtime:

```bash
cp ~/.agents/skills/testing-suite/project-checkpoints.example.md ./project-checkpoints.md
```

The `~/.agents/skills/` hub path is created by `install.sh` and works in every runtime. In runtimes
that resolve skill URIs, `skill://testing-suite/project-checkpoints.example.md` is equivalent.
If neither resolves, locate the file inside the cloned skill repo and copy it manually.

**2. Ignore it, if it should stay local.** Add the filename to `.gitignore`:

```bash
printf '\n# local review checkpoints for the testing-suite\nproject-checkpoints.md\n' >> .gitignore
```

Ignoring it **does not** affect the agents — they open the file from disk by name, and git tracking
is irrelevant to that. In a repo shared with a team, editing `.gitignore` imposes the choice on
everyone; use `.git/info/exclude` instead, which is never committed. Commit the file normally
if you want the whole team reviewed against the same checkpoints.

**3. Strip the template scaffolding.** The copy is **not** usable until two things are removed:

- **The header** (everything above `## How to write a checkpoint`) — meta-instructions about copying
  the template, which are noise inside a live file.
- **Every `## Example:` section** — these describe a different product. Left in place, all 15 agents
  treat another repo's domain as mandatory detection targets, and the review comes back flagging
  ownership chains and toast variants that do not exist here.

**Keep** the `## How to write a checkpoint` block. It is the Detect/Why/Correct-form contract the
agents parse, and the `## Optional: conventions the reviewers should not fight` heading at the end.

**4. Populate it from real history.** Do not invent checkpoints. Each one is a bug that already
happened in this repository. Harvest them from, in descending order of value: fix commits
(`git log --grep='fix\|hotfix\|revert' --oneline`), post-mortems and incident notes, `AGENTS.md` /
`CLAUDE.md` / `.cursorrules`, and long comment threads on closed bugs. Each entry needs all three
fields, or an agent cannot act on it:

```markdown
### <Short name>
**Detect:** the observable pattern in the code — what to grep for, what shape to match.
**Why:** the incident or class of bug this prevents. One sentence.
**Correct form:** what the code should look like instead.
```

`Detect` must be mechanically checkable. "Be careful with auth" is not a checkpoint; "a server
action that accepts client-supplied IDs and uses them without re-deriving ownership server-side" is.
Order entries by how much damage the bug did. Five real checkpoints beat thirty aspirational ones.

**5. Verify.** `project-checkpoints.md` is at the repo root, contains no `## Example:` heading and no
reference to a domain that is not this one, and every entry has all three fields. Then run
`/code-review` and confirm the findings cite it.

### Keeping it alive

Add a checkpoint whenever a bug escapes review — that is the signal the suite lacked the context.
Delete any checkpoint that has never caught anything; a stale detection target costs attention on
every run. The `## Optional: conventions the reviewers should not fight` section is the escape hatch
for anything the suite flags that is a deliberate choice here — a false positive belongs there
rather than in a complaint about the agent.

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
