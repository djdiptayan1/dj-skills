---
description: Run the approval-gated implementation and validation flow. Orchestrator gates; only TechLead writes.
---

Run the approved-fix implementation/testing flow for the **current project**.

The developer has approved the **findings** from a prior review. They have **not** yet approved an
implementation. `Orchestrator` collects that approval at step 4, before any file is written.

## Scope & Variables
- **`$TARGET_SCOPE`**: the uncommitted modifications/files in the current workspace (`git status` / `git diff`), unless `$ARGUMENTS` names a narrower scope.
- **`$CONFINEMENT_POLICY`**: "Audit and modify only files inside `$TARGET_SCOPE`. Do not touch committed files unless they are part of the active uncommitted modifications."
- `TechLead` is the **only** agent permitted to write. No other agent spawns anything; this playbook owns sequencing.
- Model/reasoning defaults come from each agent's own frontmatter. Escalate per the Escalation policy in `skill://testing-suite/SKILL.md`.

## Required sequence

| # | Agent | Writes? | Purpose |
|---|---|---|---|
| 1 | **DatabaseAuditor** | no | Re-check schemas, API contracts, and UI typings against the approved findings. |
| 2 | **Tester** | no | Design the smallest useful tests, plus regression cases for any project checkpoint this change could re-trigger. |
| 3 | **Critic** | no | Verify and veto the inputs; consolidate into one grounded implementation brief. |
| 4 | **Orchestrator** | no | **APPROVAL GATE.** Present the brief and stop. Proceed only on an explicit YES. |
| 5 | **TechLead** | **yes** | Implement exactly the approved brief. Nothing beyond it. |
| 6 | **Validator** | no | Run tests/typechecks, check coverage, false coverage, and flakiness after the change. |

Steps 1–3 may run in parallel where the runtime supports it **only if** `Critic` still receives both prior reports before producing the brief. Steps 4–6 are strictly sequential.

**The gate is not optional.** If step 4 is skipped, the run is invalid — stop and report it rather than
writing files. Silence or a follow-up question from the developer is not approval; only YES is.
If the developer excludes individual items, `TechLead` implements the remainder and reports what was dropped.

## Output requirements
- The consolidated brief, and what `Critic` vetoed from it, with reasons.
- The explicit approval that was given, and any items excluded.
- Exactly which files `TechLead` changed, and what changed in each.
- Typecheck and test outcomes from `Validator`, including coverage of the new logic.
- Anything blocked because it fell outside `$TARGET_SCOPE`.
- A short release-style summary, ending with remaining risk and how to roll back.

## Optional goal/context
$ARGUMENTS
