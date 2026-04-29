---
name: ae:prompt-optimize
description: "Optimize user prompts for Codex execution. Trigger on ae:prompt-optimize, /ae-prompt-optimize, optimize prompt, prompt rewrite, or improve this prompt."
---

# AE Prompt Optimize

Use this skill to turn rough user input into a structured Codex prompt.

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File <plugin-root>\scripts\ae-prompt-optimize.ps1 -Prompt "<request>"
```

Use `-Auto` only to mark the prompt as ready for direct execution. This Codex version does not create or navigate to new sessions.
