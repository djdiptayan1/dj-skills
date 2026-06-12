---
description: Run the full Antigravity subagent workflow on current uncommitted files.
---

Run the full Antigravity multi-agent suite for the **current project**.

## Scope & Variables
- **$TARGET_SCOPE**: "The uncommitted modifications/files in the current workspace (as shown by git status/git diff)."
- **$CONFINEMENT_POLICY**: "Audit and propose changes only to the uncommitted files. Do not modify or create files that are already committed unless they are part of the active uncommitted modifications."
- Restrict all work to the **current project's uncommitted files only** plus `audit.md` when present.
- Dynamically discover the active tech stack, exact package versions, schema locations, API contracts, UI routes, env/config, and test runner for this project before making claims.
- Cross-check live documentation online before judging conventions.
## Required sequence
1. **DatabaseAuditor**
   - Discover the relevant contract surface dynamically.
   - If the feature touches data, audit schema/data contracts.
   - Otherwise audit the nearest relevant contract layer (API payloads, routes, server actions, UI props/state, env/config, fixtures, or tests).
2. **Tester**
   - Audit test strategy and gaps for the same uncommitted files.
3. **Critic**
   - Run the multi-tier review loop (SDE1 -> SDE2 -> Senior -> Head of Engineering).
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
