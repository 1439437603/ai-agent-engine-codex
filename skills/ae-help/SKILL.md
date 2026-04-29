---
name: ae:help
description: "List AI Agent Engine for Codex V1 skills and usage guidance. Trigger on ae:help, /ae-help, AE help, available AE commands, or plugin capabilities."
---

# AE Help for Codex

Use this skill to explain the Codex skill pack. Prefer the dynamic help catalog script so the output stays aligned with installed skills.

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File <plugin-root>\scripts\ae-help-catalog.ps1
```

Fallback static surface:

## Skills

| Skill | Text aliases | Purpose |
| --- | --- | --- |
| `ae:lfg` | `/ae-lfg`, `ae lfg` | Main pipeline from request to verified delivery |
| `ae:brainstorm` | `/ae-brainstorm` | Clarify intent, constraints, scope, and success criteria |
| `ae:plan` | `/ae-plan` | Produce a decision-complete implementation plan |
| `ae:work` | `/ae-work` | Execute a plan with verification evidence |
| `ae:review` | `/ae-review` | Review code or documents, findings first |
| `ae:refactor` | `/ae-refactor` | Plan behavior-preserving cleanup or technical debt work |
| `ae:task-loop` | `/ae-task-loop` | Iterate on a concrete task until validation passes |
| `ae:help` | `/ae-help` | Show this help |
| `ae:gate` | `/ae-gate` | Run script-backed workflow evidence gates |
| `ae:recovery` | `/ae-recovery` | Recover workflow state from existing artifacts |
| `ae:review-contract` | `/ae-review-contract` | Generate reviewer selection and gate rules |

## V1 Boundaries

- V1 provides Codex skills only, not native slash commands.
- Core gate, recovery, and review-contract checks are available as script-backed Codex skills.
- Specialized tools for Swagger, Figma, SQL, browser automation, dynamic catalogs, and cross-session transfer are not included yet.
- When a workflow needs proof, use Codex-visible evidence: file checks, git status, lint/typecheck/test output, screenshots when available, and final evidence summaries.

## Recommended Use

- For a complete feature or fix: use `ae:lfg`.
- For unclear requirements: use `ae:brainstorm`.
- For an already scoped task: use `ae:plan`, then `ae:work`.
- For quality checks: use `ae:review`.
- For delivery proof: use `ae:gate`.
- For resuming work: use `ae:recovery`.
