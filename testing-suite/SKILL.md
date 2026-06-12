---
name: testing-suite
description: Dynamic multi-agent validation and implementation suite (DatabaseAuditor -> Tester -> Critic -> Orchestrator -> TechLead -> Validator).
---

# Testing Suite

This testing-suite is a plug-and-play multi-agent framework designed to perform validation, peer-review criticism, test design, and architecture-compliant code modifications.

## Discovered Agent Services
- **DatabaseAuditor** (`skill://testing-suite/agents/database-auditor.md`): Dynamically resolves contract surfaces (schemas, API boundaries, UI typings) and validates compatibility.
- **Tester** (`skill://testing-suite/agents/tester.md`): Detects active test runners (Vitest/Playwright/Jest) and designs comprehensive, non-flaky test specifications.
- **Critic** (`skill://testing-suite/agents/critic.md`): Multi-tier peer-review pipeline (SDE 1 -> SDE 2 -> Senior -> Head of Engineering) ensuring correctness.
- **Orchestrator** (`skill://testing-suite/agents/orchestrator.md`): Unified report gatekeeper. Evaluates results, displays recommendations, and requests explicit approval.
- **TechLead** (`skill://testing-suite/agents/tech-lead.md`): The ONLY write-authorized agent in this suite. Implements verified changes safely.
- **Validator** (`skill://testing-suite/agents/validator.md`): Verifies test outcomes, code typechecking, and regression tests.

## Active Sequence Playbooks
- **Uncommitted Audit**: `skill://testing-suite/playbooks/run-all-subagents.md`
- **Full Repository Audit**: `skill://testing-suite/playbooks/run-all-subagents-full.md`
- **Feature-Targeted Audit**: `skill://testing-suite/playbooks/run-all-subagents-feature.md`
- **Implementation & Post-Verify**: `skill://testing-suite/playbooks/apply-approved-suite.md`

## How to Run
1. Read the agent configs and sequence playbooks using `skill://testing-suite/agents/<agent-name>.md` and `skill://testing-suite/playbooks/<playbook-name>.md`.
2. Configure `$TARGET_SCOPE` and `$CONFINEMENT_POLICY` dynamically at execution time.
3. Spawn subagents via the `task` tool sequentially.
