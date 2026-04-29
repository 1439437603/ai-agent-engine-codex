# AI Agent Engine for Codex

[中文说明](README.zh-CN.md)

This is the Codex-native V1 migration of AI Agent Engine. It is intentionally a skill-first plugin: it exposes AE's core engineering workflows as Codex skills and does not include the original platform-specific TypeScript plugin server, custom runtime tools, TUI integration, or command registry.

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
| `ae:help` | Static help for this V1 skill pack |

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

## V1 Boundaries

The first version focuses on stable Codex skill behavior. Swagger parsing, Figma export, SQL execution, browser automation, dynamic help generation, and runtime handoff tools are intentionally left for a later MCP or script-backed migration.
