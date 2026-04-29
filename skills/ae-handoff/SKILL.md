---
name: ae:handoff
description: "Create a Codex session handoff document. Trigger on ae:handoff, /ae-handoff, hand off this session, resume context, or create continuation summary."
---

# AE Handoff

Use this skill when work needs to continue in another session.

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File <plugin-root>\scripts\ae-handoff.ps1 -Title "handoff" -Goal "continue work" -Status running -Evidence "tests pass" -NextStep "next task"
```

The script writes `docs/ae/handoffs/YYYY-MM-DD-*.md` with the goal, status, evidence, unfinished work, and restore instructions.
