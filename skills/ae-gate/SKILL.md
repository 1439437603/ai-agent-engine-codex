---
name: ae:gate
description: "Run Codex-native AE evidence gates. Trigger on ae:gate, /ae-gate, gate check, delivery gate, before-work gate, before-review gate, or final proof."
---

# AE Gate

Use this skill when an AE workflow needs a machine-checkable evidence gate before work, before review, or final delivery.

## Script

Run from the target project root or pass `-Root` explicitly:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File <plugin-root>\scripts\ae-gate.ps1 `
  -Workflow lfg `
  -Checkpoint final `
  -PlanPath docs/ae/plans/example-plan.md `
  -ValidationCommand "npm test" `
  -ReviewStatus passed
```

## Behavior

- Returns JSON with `status`, `blockers`, `warnings`, `evidence`, and optional `proofPath`.
- Blocks when required plan, validation, review, or authorization evidence is missing.
- Writes a proof JSON under `docs/ae/gates/` for `final` checkpoints or when `-WriteProof` is set.

## Use In Workflows

- `before_work`: confirm the plan artifact exists.
- `before_review`: confirm validation commands were actually run.
- `final`: confirm validation and review status before claiming completion.
