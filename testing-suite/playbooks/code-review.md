---
description: Run a read-only 9-agent code review grounded in Clean Code & Clean Coder principles with scope inference and synthesized verdict.
---

Run a comprehensive, read-only code review for the current project.

## Scope inference
Set `$TARGET_SCOPE` using the first matching rule:
1. If `$ARGUMENTS` names a branch, commit SHA, PR number/URL, or file paths, review that scope.
2. If there are uncommitted or staged changes, review `git diff` plus `git diff --staged`.
3. If on a feature branch, review the branch diff against `main` or `master` with `git diff main...HEAD` or `git diff master...HEAD`.
4. If there is no active diff, review `git show HEAD`.

Set `$CONFINEMENT_POLICY` to:
"Read-only review. Audit and run safe read-only checks only for `$TARGET_SCOPE`. Do not edit files, do not run auto-fixes, and do not produce implementation changes."

## Required agents
Apply the Model Routing section from `skill://testing-suite/SKILL.md` before launching agents so mechanical checks use lower reasoning and high-risk reviewers can escalate.

Launch all 9 agents in parallel when the runtime supports parallel task calls. If not, run them sequentially in this order:
1. `skill://testing-suite/agents/test-runner.md`
2. `skill://testing-suite/agents/linter-static-analysis.md`
3. `skill://testing-suite/agents/code-reviewer.md` (Clean Code principles: Law of Demeter, CQS, Stepdown Rule, Null Hygiene, SRP)
4. `skill://testing-suite/agents/security-reviewer.md`
5. `skill://testing-suite/agents/quality-style-reviewer.md`
6. `skill://testing-suite/agents/test-quality-reviewer.md` (Clean Coder standards: F.I.R.S.T., 3 TDD Laws, Single Concept, Test Pyramid)
7. `skill://testing-suite/agents/performance-reviewer.md`
8. `skill://testing-suite/agents/dependency-deployment-reviewer.md`
9. `skill://testing-suite/agents/simplification-maintainability-reviewer.md`

Each agent must receive the resolved `$TARGET_SCOPE`, `$CONFINEMENT_POLICY`, and any user context from `$ARGUMENTS`.

## Synthesis
After all agents complete, run `skill://testing-suite/agents/orchestrator.md` in code-review mode. It must:
1. Separate issues that should be fixed from optional suggestions.
2. Rank severity across agents: Critical > High > Medium > Low.
3. Require concise `Current` vs `Clean Code Recommendation` code blocks for Critical and High issues.
4. Collapse clean agent reports into one-line all-clear entries.
5. Give one verdict:
   - `Ready to Merge`: tests pass or are not applicable, no critical/high issues, suggestions optional.
   - `Needs Attention`: medium issues or important suggestions worth addressing.
   - `Needs Work`: critical/high issues or failing tests.

## Output format
```
## Code Review Summary

PR Owner: <name or "Local Developer">
Title: <PR/Commit title or "Code Review Summary">
Intent: <1-2 sentence summary of reviewed changes>

### Executive Summary
- Overall Risk: <Low | Medium | High>
- Test Pyramid Status: <Unit / Integration / E2E evaluation>

### Needs Attention (X issues)
1. [Agent / Category] Issue title - file:line
   - Problem: Brief description
   - Clean Code Recommendation:
     ```typescript
     // Current vs Recommended code block
     ```

### Suggestions (X items)
1. [Quality] Title (HIGH impact, LOW effort) - file:line
   Brief description

### All Clear
Tests (N passed), Linter (no issues), Security (no concerns)

### Verdict: [Ready to Merge | Needs Attention | Needs Work]
[One sentence summary of what to do next]
```
