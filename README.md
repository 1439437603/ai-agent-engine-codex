# AI Agent Engine for Codex

[中文说明](README.zh-CN.md)

This is the Codex-native migration of AI Agent Engine. It is intentionally a skill-first plugin: it exposes AE's core engineering workflows as Codex skills and script-backed checks without the original platform-specific TypeScript plugin server, TUI integration, or command registry.

## Included Skills

| Skill | Use it for |
| --- | --- |
| `ae:lfg` | End-to-end delivery from request to verified result |
| `ae:brainstorm` | Requirements discovery and scoped design |
| `ae:plan` | Decision-complete implementation plans |
| `ae:work` | Executing an existing plan with verification |
| `ae:review` | Code or document review with findings first |
| `ae:refactor` | Behavior-preserving cleanup planning |
| `ae:task-loop` | Iterative fix-and-verify loops |
| `ae:help` | Static help for this skill pack |
| `ae:gate` | Script-backed evidence gates for workflow checkpoints |
| `ae:recovery` | Script-backed recovery recommendations from existing artifacts |
| `ae:review-contract` | Script-backed reviewer selection and gate rules |

`/ae-*` text such as `/ae-lfg` is supported as a trigger phrase in skill descriptions. V1 does not implement native slash commands.

## Local Use

Use this directory as a local Codex plugin source. The plugin manifest is:

```text
D:\yanjiu\ai-agent-engine-codex\.codex-plugin\plugin.json
```

This project does not update global Codex marketplace configuration automatically. If you want UI installation later, add this plugin directory to your local marketplace by hand or ask for that as a separate step.

## Verification

Run from this plugin root:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\validate-plugin.ps1
```

The validator checks plugin JSON, skill frontmatter, required skill files, and common incompatibility leftovers from the source platform.

## V2 Core Closure

The first post-V1 migration adds script-backed replacements for the most important opencode custom tools:

- `scripts/ae-gate.ps1` returns pass/block gate results and can write proof JSON to `docs/ae/gates/`.
- `scripts/ae-recovery.ps1` scans `docs/ae/brainstorms/`, `docs/ae/plans/`, and `docs/ae/gates/` to recommend the next AE skill.
- `scripts/ae-review-contract.ps1` returns reviewer perspectives and gate rules for code or document review.

Run the focused core-tool test suite with:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\test-core-tools.ps1
```

## V2 Boundaries

The current version focuses on stable Codex skill behavior plus core gate, recovery, and review-contract checks. Swagger parsing, Figma export, SQL execution, browser automation, dynamic help generation, and runtime handoff tools are intentionally left for a later MCP or script-backed migration.
