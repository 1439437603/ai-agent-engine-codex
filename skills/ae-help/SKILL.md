---
name: ae:help
description: "List AI Agent Engine for Codex V1 skills and usage guidance. Trigger on ae:help, /ae-help, AE help, available AE commands, or plugin capabilities."
---

# AE Help for Codex

Use this skill to explain the V1 Codex skill pack. Do not scan the source repository unless the user asks for implementation details; the stable V1 surface is listed below.

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

## V1 Boundaries

- V1 provides Codex skills only, not native slash commands.
- Specialized tools for Swagger, Figma, SQL, browser automation, dynamic catalogs, and cross-session transfer are not included yet.
- When a workflow needs proof, use Codex-visible evidence: file checks, git status, lint/typecheck/test output, screenshots when available, and final evidence summaries.

## Recommended Use

- For a complete feature or fix: use `ae:lfg`.
- For unclear requirements: use `ae:brainstorm`.
- For an already scoped task: use `ae:plan`, then `ae:work`.
- For quality checks: use `ae:review`.
