---
name: ae:document-review
description: "Review requirements, plans, test specs, or general documents in Codex. Trigger on ae:document-review, /ae-document-review, document review, requirements review, plan review, or test spec review."
---

# AE Document Review

Use this skill for document-specific review. It is a focused wrapper around `ae:review` and `ae:review-contract`.

Workflow:

1. Read the target document.
2. Run `ae:review-contract` with `-Kind document`, `-Kind plan`, `-Kind test`, or `-Kind general` as appropriate.
3. Review for consistency, feasibility, missing acceptance criteria, hidden assumptions, and unverifiable claims.
4. Report findings first, then residual risks.
