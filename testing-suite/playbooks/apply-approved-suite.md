---
description: After approval, run TechLead and Validator on the verified uncommitted-file plan.
---

The developer has **already approved implementation**.

Continue the Antigravity workflow for the **current project** with these rules:

## Scope & Variables
- **$TARGET_SCOPE**: "The uncommitted modifications/files in the current workspace (as shown by git status/git diff)."
- **$CONFINEMENT_POLICY**: "Audit and modify only the uncommitted files. Do not touch or modify files that are already committed unless they are part of the active uncommitted modifications."
- Restrict all work to the **current project's uncommitted files only** plus `audit.md` when present.
- TechLead is the only agent allowed to write.
## Required sequence
1. Re-read the latest Orchestrator/Critic findings for the approved plan.
2. Run **TechLead** to implement only the verified changes in uncommitted files.
3. Run **Validator** to verify typecheck/tests/safety.
4. Run **Critic** one final time to catch regressions or weak fixes.
5. Run **Orchestrator** to present the final post-change report.

## Output requirements
- Show exactly which files TechLead changed.
- Report typecheck/test outcomes.
- Report any remaining issues.
- End with a release-style summary for the developer.

## Optional goal/context
$ARGUMENTS
