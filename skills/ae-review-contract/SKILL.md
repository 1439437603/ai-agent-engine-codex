---
name: ae:review-contract
description: "Generate a Codex-native AE review contract. Trigger on ae:review-contract, /ae-review-contract, review contract, reviewer selection, or review gate rules."
---

# AE Review Contract

Use this skill before a structured review when you need a repeatable reviewer set and gate rules.

## Script

Run from the plugin root or pass full path to the script:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File <plugin-root>\scripts\ae-review-contract.ps1 `
  -Kind code `
  -Mode autofix `
  -HasSecurity `
  -HasApi `
  -ChangedLines 250
```

## Behavior

- Returns JSON with `kind`, `documentType`, `mode`, `reviewers`, `gate`, and `rules`.
- Always includes baseline reviewers.
- Adds specialist reviewers for security, API, reliability, performance, data evolution, tooling, UI, architecture, and product risks.

## Use In Workflows

Feed the selected reviewers into `ae:review` as checklist perspectives. P0/P1 findings should block delivery unless the user explicitly accepts the risk.
