---
description: Run the full Antigravity subagent workflow on a targeted feature, specific directories, or specific files.
---

Run the full Antigravity multi-agent suite for a **specific feature or files** in the project.

## Scope & Variables
- **$TARGET_SCOPE**: "The targeted feature paths, directories, or specific files specified in the arguments ($ARGUMENTS)."
- **$CONFINEMENT_POLICY**: "Strictly confine all audits, criticisms, testing recommendations, and implemented modifications to the directory or file paths of the targeted feature. Do not make modifications outside this module boundary."
- Dynamically discover the active tech stack, exact package versions, schema locations, API contracts, UI routes, env/config, and test runner for this project before making claims.
- Cross-check live documentation online before judging conventions.

## Required sequence
1. **DatabaseAuditor**
   - Discover the contract surface relevant to the targeted feature dynamically.
   - Audit schemas, API payloads, actions, forms, UI data shapes, fixtures, or tests within the feature boundary.
2. **Tester**
   - Audit test strategy and gaps for the targeted feature.
3. **Critic**
   - Run the multi-tier review loop (SDE1 -> SDE2 -> Senior -> Head of Engineering) strictly confined to the feature's scope.
   - Veto findings that fall outside the feature paths.
4. **Orchestrator**
   - Produce the final gatekeeper report.
   - Tell me what is bad, what is broken, what differs, what current docs say, and exact recommended changes.
5. **TechLead**
   - **Do not run unless I explicitly approve in this conversation.**
   - TechLead is the only agent allowed to write inside the feature boundary.
6. **Validator**
   - Run only after TechLead finishes.
   - Verify typecheck/tests/safety of the implemented changes.

## Output requirements
- Show a concise stage-by-stage summary.
- Then show the final Orchestrator gatekeeper report.
- If no explicit approval has been given yet, stop after Orchestrator and ask whether to proceed with TechLead.

## Optional goal/context
$ARGUMENTS
