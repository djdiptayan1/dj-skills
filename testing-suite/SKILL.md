---
name: testing-suite
description: Dynamic multi-agent validation, code review, and implementation suite.
---

# Testing Suite

This testing-suite is a plug-and-play multi-agent framework designed to perform read-only code review, validation, peer-review criticism, test design, and approval-gated architecture-compliant code modifications.

## Discovered Agent Services
- **TestRunner** (`skill://testing-suite/agents/test-runner.md`): Runs the smallest relevant read-only tests and reports pass/fail details.
- **LinterStaticAnalysis** (`skill://testing-suite/agents/linter-static-analysis.md`): Runs read-only lint/typecheck diagnostics and reports fixability.
- **CodeReviewer** (`skill://testing-suite/agents/code-reviewer.md`): Reports up to 5 non-obvious code improvements ranked by impact and effort.
- **SecurityReviewer** (`skill://testing-suite/agents/security-reviewer.md`): Checks injection, auth, secrets, and sensitive error handling risks.
- **QualityStyleReviewer** (`skill://testing-suite/agents/quality-style-reviewer.md`): Reviews complexity, dead code, duplication, and project conventions.
- **TestQualityReviewer** (`skill://testing-suite/agents/test-quality-reviewer.md`): Reviews coverage ROI, behavior focus, test code quality, and flakiness.
- **PerformanceReviewer** (`skill://testing-suite/agents/performance-reviewer.md`): Checks N+1s, blocking work, render churn, leaks, and hot paths.
- **DependencyDeploymentReviewer** (`skill://testing-suite/agents/dependency-deployment-reviewer.md`): Reviews dependency, compatibility, migration, rollout, and observability risks.
- **SimplificationMaintainabilityReviewer** (`skill://testing-suite/agents/simplification-maintainability-reviewer.md`): Checks whether the change can be simpler and better scoped.
- **DatabaseAuditor** (`skill://testing-suite/agents/database-auditor.md`): Dynamically resolves contract surfaces (schemas, API boundaries, UI typings) and validates compatibility.
- **Tester** (`skill://testing-suite/agents/tester.md`): Detects active test runners (Vitest/Playwright/Jest) and designs comprehensive, non-flaky test specifications.
- **Critic** (`skill://testing-suite/agents/critic.md`): Multi-tier peer-review pipeline (SDE 1 -> SDE 2 -> Senior -> Head of Engineering) ensuring correctness.
- **Orchestrator** (`skill://testing-suite/agents/orchestrator.md`): Unified report gatekeeper. Evaluates results, displays recommendations, and requests explicit approval.
- **TechLead** (`skill://testing-suite/agents/tech-lead.md`): The ONLY write-authorized agent in this suite. Implements verified changes safely.
- **Validator** (`skill://testing-suite/agents/validator.md`): Verifies test outcomes, code typechecking, and regression tests.

## Default Playbooks
- **Review My Code**: `skill://testing-suite/playbooks/code-review.md`
- **Apply Approved Fixes**: `skill://testing-suite/playbooks/apply-approved-suite.md`

## Flow Summary
- **9-agent review flow** (`code-review.md`): read-only. Use this for uncommitted code, PR files, branch diffs, commits, or file paths. It runs focused reviewers for tests, lint, code, security, style, test quality, performance, deployment, and simplification, then `Orchestrator` gives a merge verdict.
- **6-agent implementation flow** (`apply-approved-suite.md`): write-gated. Use this only after review findings are approved. It runs `DatabaseAuditor -> Tester -> Critic -> TechLead -> Validator -> Orchestrator`; only `TechLead` may write, and `Validator` runs the post-change tests/typechecks.

## Recommended Routing
- Use **Review My Code** for the common case: uncommitted files, files in a PR, or a branch before merge.
- Use **Apply Approved Fixes** only after review findings are approved.
- For maximum testing confidence, run **Apply Approved Fixes** after approved changes so `Validator` reruns tests/typechecks and `Critic` checks the fix.

## Model Routing
- These agents are model-agnostic. If your runtime supports per-agent model overrides, override the `model` frontmatter using this section.
- Gemini default: use **Gemini 3.5 Flash**. Keep `thinkingLevel: low` for mechanical checks, `medium` for normal review, and `high` only for security, deployment, architecture, implementation, and final validation.
- Claude default: use **Sonnet** for TestRunner, LinterStaticAnalysis, CodeReviewer, QualityStyleReviewer, TestQualityReviewer, PerformanceReviewer, SimplificationMaintainabilityReviewer, Tester, and DatabaseAuditor.
- Claude escalation: use **Opus** for SecurityReviewer, DependencyDeploymentReviewer, Critic, Orchestrator, TechLead, and Validator when the change touches auth, money, migrations, data integrity, public APIs, production rollout, or failed tests.
- Token rule: start with the cheapest listed model/reasoning level; escalate only when the agent reports uncertainty, high-risk findings, failing tests, or conflicting evidence.

## How to Run
1. Read the agent configs and sequence playbooks using `skill://testing-suite/agents/<agent-name>.md` and `skill://testing-suite/playbooks/<playbook-name>.md`.
2. Configure `$TARGET_SCOPE` and `$CONFINEMENT_POLICY` dynamically at execution time.
3. For `code-review.md`, spawn the 9 review agents in parallel when supported, otherwise sequentially.
4. For `apply-approved-suite.md`, spawn the 6 implementation agents sequentially and keep writes limited to `TechLead`.
