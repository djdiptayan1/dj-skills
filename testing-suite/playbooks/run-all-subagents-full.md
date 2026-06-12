---
description: Run the full Antigravity subagent workflow on all codebase files (committed and uncommitted).
---

Run the full Antigravity multi-agent suite for the **current project** across all files.

## Scope & Variables
- **$TARGET_SCOPE**: "The entire workspace codebase directory (all committed and uncommitted source and configuration files)."
- **$CONFINEMENT_POLICY**: "Propose standard-compliant refactors and optimizations across any relevant file in the project. TechLead has permission to modify existing codebase files or create new files to satisfy standards and resolve bugs."
- Dynamically discover the active tech stack, exact package versions, schema locations, API contracts, UI routes, env/config, and test runner for this project before making claims.
- Cross-check live documentation online before judging conventions.

## Required sequence
1. **DatabaseAuditor**
   - Discover the relevant contract surface dynamically.
   - Audit all schemas, API payloads, routes, server actions, UI props/state, env/config, fixtures, or tests.
2. **Tester**
   - Audit test strategy and gaps for all code.
3. **Critic**
   - Run the multi-tier review loop (SDE1 -> SDE2 -> Senior -> Head of Engineering) across all codebase audits.
   - Veto weak or out-of-scope findings.
4. **Orchestrator**
   - Produce the final gatekeeper report.
   - Tell me what is bad, what is broken, what differs, what current docs say, and exact recommended changes.
5. **TechLead**
   - **Do not run unless I explicitly approve in this conversation.**
   - TechLead is the only agent allowed to write.
6. **Validator**
   - Run only after TechLead finishes.
   - Verify typecheck/tests/safety of the implemented changes.

## Output requirements
- Show a concise stage-by-stage summary.
- Then show the final Orchestrator gatekeeper report.
- If no explicit approval has been given yet, stop after Orchestrator and ask whether to proceed with TechLead.

## Optional goal/context
$ARGUMENTS
