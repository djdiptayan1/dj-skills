---
description: After approval, run the 6-agent implementation and testing flow.
---

The developer has **already approved implementation**.

Run the 6-agent approved implementation/testing flow for the **current project**.

## Scope & Variables
- **$TARGET_SCOPE**: "The uncommitted modifications/files in the current workspace (as shown by git status/git diff)."
- **$CONFINEMENT_POLICY**: "Audit and modify only the uncommitted files. Do not touch or modify files that are already committed unless they are part of the active uncommitted modifications."
- Restrict all work to the **current project's uncommitted files only** plus `audit.md` when present.
- TechLead is the only agent allowed to write.
- Apply the Model Routing section from `skill://testing-suite/SKILL.md` before launching agents.
## Required sequence
1. **DatabaseAuditor**: re-check schemas, API contracts, UI typings, or nearest data-bearing contracts for the approved findings.
2. **Tester**: identify the smallest useful tests and test gaps for the approved findings.
3. **Critic**: consolidate the approved findings, contract risks, and test plan into a strict implementation brief.
4. **TechLead**: implement only the approved and consolidated changes. TechLead is the only writer.
5. **Validator**: run the relevant tests/typechecks and check coverage/flakiness risks after implementation.
6. **Orchestrator**: present the final post-change report and remaining risks.

## Output requirements
- Show exactly which files TechLead changed.
- Report typecheck/test outcomes.
- Report any remaining issues.
- End with a release-style summary for the developer.

## Optional goal/context
$ARGUMENTS
