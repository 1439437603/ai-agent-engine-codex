---
name: ae:work
description: "Execute an existing plan or scoped task in Codex with safe edits, verification, and evidence. Trigger on ae:work, /ae-work, execute this plan, implement the plan, or continue until verified."
---

# AE Work

Use this skill to implement a scoped task or an existing plan. It is action-oriented and must end with verification evidence or a clear blocker.

## Execution Protocol

1. Restate the target and completion criteria.
2. Read applicable `AGENTS.md` files and relevant source context before editing.
3. Check current git status and preserve unrelated user changes.
4. Break the work into small steps and keep the user updated.
5. Before edits, identify the exact files or directories to change.
6. Make the smallest viable implementation.
7. Run the verification defined by the plan; if none exists, choose the minimum useful checks.
8. Run `ae:gate` at `final` for substantial delivery, passing the plan path, validation command, and review status when available.
9. If verification fails, classify the failure and continue iterating while a recovery path exists.
10. Final response must include target, result, evidence, risks, and highest-ROI next step.

## Verification Defaults

Prefer, in order:

- Project-specific test command from package/config/docs.
- Typecheck or compile command.
- Lint or static validation.
- Focused manual checks with exact evidence.

## Safety Rules

- Never claim success without reading verification output.
- Never overwrite unrelated changes.
- Avoid new dependencies unless the user explicitly requested them or the plan requires them.
- Use durable evidence: command output summaries, changed file list, and remaining risks.
