# AI Agent Engine for Codex

[中文说明](README.zh-CN.md)

AI Agent Engine for Codex is an original Codex-native engineering operating system. It turns product intent into structured requirements, executable plans, verified implementation loops, review contracts, recovery guidance, and delivery evidence through a skill-first plugin plus local safety scripts.

This project is positioned as a new innovation surface for Codex, not as a port of another runtime. Anything not implemented yet is tracked as a planned optimization or planned development capability.

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
| `ae:help` | Dynamic help for this skill pack |
| `ae:gate` | Script-backed evidence gates for workflow checkpoints |
| `ae:recovery` | Script-backed recovery recommendations from existing artifacts |
| `ae:review-contract` | Script-backed reviewer selection and gate rules |
| `ae:swagger-parser` | Swagger/OpenAPI overview and endpoint detail summaries |
| `ae:prompt-optimize` | Prompt restructuring without new-session automation |
| `ae:document-review` | Document-specific review workflow |
| `ae:save-rules` | Persist reusable rules under `docs/ae/rules/` |
| `ae:handoff` | Write handoff packets under `docs/ae/handoffs/` |
| `ae:frontend-design` | Codex-native frontend design workflow |
| `ae:test-browser` | Browser acceptance workflow with explicit local boundaries |
| `ae:sql` | Safe SQL intent classifier and wrapper |
| `ae:figma-assets` | Authorized local Figma asset collection placeholder |
| `ae:update` | Clean-tree update and validation workflow |

`/ae-*` text such as `/ae-lfg` is supported as a trigger phrase in skill descriptions. Native command registration is a planned development item.

## Local Use

Use this directory as a local Codex plugin source. The plugin manifest is:

```text
D:\yanjiu\ai-agent-engine-codex\.codex-plugin\plugin.json
```

This project does not update global Codex marketplace configuration automatically. To make local installation repeatable, use the reversible local marketplace helper instead of editing Codex state by hand:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\register-local-marketplace.ps1
```

The helper writes a local marketplace under `%USERPROFILE%\.codex\local-marketplaces\ae-codex`, copies a clean plugin snapshot into that marketplace, and mirrors the same version into `%USERPROFILE%\.codex\plugins\cache\ae-local\ai-agent-engine-codex\`.

To remove those local registration artifacts:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\unregister-local-marketplace.ps1
```

## Verification

Run from this plugin root:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\validate-plugin.ps1
```

The validator checks plugin JSON, skill frontmatter, required skill files, trigger aliases, expected local scripts, documentation boundaries, and blocked legacy-positioning terms.

Run the focused test suites with:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\test-core-tools.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\test-roadmap-surface.ps1
```

## Current Innovation Surface

- `scripts/ae-gate.ps1` returns pass/block gate results and can write proof JSON to `docs/ae/gates/`.
- `scripts/ae-recovery.ps1` scans `docs/ae/brainstorms/`, `docs/ae/plans/`, and `docs/ae/gates/` to recommend the next AE skill.
- `scripts/ae-review-contract.ps1` returns reviewer perspectives and gate rules for code or document review.
- `scripts/ae-swagger-parser.ps1` summarizes local Swagger/OpenAPI JSON and is tested against golden fixtures.
- `scripts/register-local-marketplace.ps1` and `scripts/unregister-local-marketplace.ps1` provide reversible local marketplace registration, marketplace plugin snapshots, and local cache cleanup.
- SQL, Figma, browser, and frontend capabilities are represented with safe skill boundaries until credentialed execution is designed and verified.

## Planned Optimization

- Improve dynamic help ranking so the most relevant AE skill is surfaced from user intent.
- Add richer recovery scoring based on current git state, recent handoffs, proof files, and failed checks.
- Strengthen review contracts with severity calibration, reviewer rationale, and automatic residual-risk prompts.
- Add CI parity checks for Windows PowerShell, PowerShell Core, and hosted runners.

## Planned Development

- Native command registration for `/ae-*` style entry points when the plugin runtime supports it safely.
- Credential-aware Figma export with explicit token handling, audit logs, and reversible local writes.
- Read-only SQL inspection profiles plus optional guarded SQL execution after allowlisted confirmation.
- Browser acceptance automation with screenshots, console capture, cancellation handling, and artifact summaries.
- A first-party project memory layer for reusable rules, handoffs, and delivery proof across Codex sessions.
