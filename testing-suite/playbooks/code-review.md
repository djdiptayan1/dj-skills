---
description: Run a read-only 9-agent code review grounded in Clean Code & Clean Coder, with scope inference and a synthesized merge verdict.
---

Run a comprehensive, **read-only** code review for the current project.

## Scope inference
Set `$TARGET_SCOPE` using the first matching rule:
1. If `$ARGUMENTS` names a branch, commit SHA, PR number/URL, or file paths, review that scope.
2. If there are uncommitted or staged changes, review `git diff` plus `git diff --staged`.
3. If on a feature branch, review the branch diff against `main` or `master` (`git diff main...HEAD`).
4. If there is no active diff, review `git show HEAD`.

Set `$CONFINEMENT_POLICY` to:
> "Read-only review. Audit and run safe read-only checks only for `$TARGET_SCOPE`. Do not edit files, do not run auto-fixes, and do not produce implementation changes."

## Project context
Before launching agents, note whether the repository has a `project-checkpoints.md`, `AGENTS.md`,
`CLAUDE.md`, or `.cursorrules`. Pass their paths to every agent. These carry the repo's own
conventions and known failure modes, and they **override** generic book heuristics wherever they
conflict. A template lives at `skill://testing-suite/project-checkpoints.example.md`.

## Required agents
Launch all 9 in parallel when the runtime supports parallel task calls; otherwise sequentially in
this order. Model and reasoning defaults come from each agent's own frontmatter — see the
Escalation policy in `skill://testing-suite/SKILL.md`.

| # | Agent | Reviews for |
|---|---|---|
| 1 | `agents/test-runner.md` | Test results, run duration, and E1/E2 one-step build & test |
| 2 | `agents/linter-static-analysis.md` | Lint, typecheck, LSP diagnostics |
| 3 | `agents/code-reviewer.md` | Naming, function size & abstraction, arguments, CQS, Law of Demeter, null hygiene, SRP |
| 4 | `agents/security-reviewer.md` | Injection, authz, secrets, prompt boundaries, leaky errors |
| 5 | `agents/quality-style-reviewer.md` | Duplication, comments (C1–C5), dead code, clutter, consistency |
| 6 | `agents/test-quality-reviewer.md` | F.I.R.S.T., single concept, sufficiency (T1–T9), pyramid placement |
| 7 | `agents/performance-reviewer.md` | N+1s, blocking work, render churn, leaks, unbounded loads |
| 8 | `agents/dependency-deployment-reviewer.md` | Dependencies, boundary wrapping & learning tests, migrations, rollout |
| 9 | `agents/simplification-maintainability-reviewer.md` | Beck's Four Rules, YAGNI, scope atomicity |

Each agent must receive the resolved `$TARGET_SCOPE`, `$CONFINEMENT_POLICY`, the project-context
paths above, and any user context from `$ARGUMENTS`.

No agent in this mode spawns another, and none may write. This playbook owns sequencing.

## Synthesis
After all agents complete, run `skill://testing-suite/agents/orchestrator.md` in **code-review mode**.
Its synthesis rules, verdict rules, and output format are defined there — that file is the single
source of truth for the report shape. Do not restate them here.

Two rules are load-bearing enough to repeat:
- **Test results and test sufficiency are separate lines.** "Tests passed" does not mean "the change is covered."
- **"No tests applicable" is not an all-clear.** It is a coverage finding.
