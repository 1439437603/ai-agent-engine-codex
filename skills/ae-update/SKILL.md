---
name: ae:update
description: "Update and validate the AI Agent Engine Codex plugin. Trigger on ae:update, /ae-update, update AE plugin, refresh plugin, or validate latest version."
---

# AE Update

Use this skill to update and validate this plugin repository.

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File <plugin-root>\scripts\ae-update.ps1
```

The script requires a clean working tree, optionally pulls with fast-forward only, and runs the plugin validator.
