---
name: ae:figma-assets
description: "Collect authorized local Figma assets or plan Figma export in Codex. Trigger on ae:figma-assets, /ae-figma-assets, Figma assets, export design assets, or collect design files."
---

# AE Figma Assets

Use this skill for Figma-related asset handoff.

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File <plugin-root>\scripts\ae-figma-assets.ps1 -SourcePath <authorized-local-path> -OutputPath <output-path>
```

This version only supports authorized local asset collection. Figma API export requires an explicit token and output policy in a later version.
