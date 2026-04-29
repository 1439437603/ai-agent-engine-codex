---
name: ae:save-rules
description: "Save reusable project rules without editing AGENTS.md automatically. Trigger on ae:save-rules, /ae-save-rules, save rule, remember this project rule, or persist coding guideline."
---

# AE Save Rules

Use this skill to persist durable project guidance under `docs/ae/rules/`.

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File <plugin-root>\scripts\ae-save-rules.ps1 -Category runtime -Content "Always verify before completion."
```

This skill does not edit `AGENTS.md` automatically. If a rule should become workspace-level policy, propose a patch separately.
