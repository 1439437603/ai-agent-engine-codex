---
name: ae:recovery
description: "Recover AE workflow state from Codex-visible artifacts. Trigger on ae:recovery, /ae-recovery, recover AE session, resume AE workflow, or find next AE step."
---

# AE Recovery

Use this skill at the start of an AE workflow when previous artifacts may already exist.

## Script

Run from the target project root or pass `-Root` explicitly:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File <plugin-root>\scripts\ae-recovery.ps1 `
  -Phase lfg
```

## Behavior

- Scans `docs/ae/brainstorms/`, `docs/ae/plans/`, and `docs/ae/gates/`.
- Returns JSON with `status`, `recommendedNextSkill`, `fallbackSkill`, `confidence`, and candidate artifact paths.
- Does not modify files.

## Recovery Semantics

- Existing requirements but no plan: continue with `ae:plan`.
- Existing plan: continue with `ae:work`.
- No artifacts: start with `ae:brainstorm`.
