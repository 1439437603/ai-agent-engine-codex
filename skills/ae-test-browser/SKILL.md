---
name: ae:test-browser
description: "Validate browser UI behavior using Codex browser tooling or Playwright. Trigger on ae:test-browser, /ae-test-browser, browser test, UI acceptance, E2E check, or page validation."
---

# AE Test Browser

Use this skill to validate web UI rendering and interactions.

Preferred order:

1. Use Codex browser-use plugin when available.
2. Use Playwright when the project already supports it.
3. If no browser automation is available, produce a manual acceptance checklist with exact URLs, steps, and expected results.

Do not depend on `agent-browser`.
