---
name: ae:review
description: "Review code, documents, plans, or current git changes in Codex. Trigger on ae:review, /ae-review, code review, document review, review this plan, or review my changes."
---

# AE Review

Use this skill for findings-first review. Prioritize correctness, regressions, missing tests, security, data loss, integration contracts, and maintainability risks.

## Scope Selection

Use the most specific available scope:

1. User-provided file, directory, commit, diff, or document path.
2. Current git diff.
3. Recent relevant files discovered from the request.

If no reviewable artifact exists, explain the missing scope and suggest the smallest useful target.

## Review Workflow

1. Read relevant instructions and the target artifact.
2. Understand intended behavior before judging implementation.
3. Use `ae:review-contract` when the review scope has security, API, performance, data evolution, tooling, UI, or architecture risk.
4. Check edge cases, failure modes, tests, integration contracts, and user-visible behavior.
5. Report findings first, ordered by severity.
6. Include precise file and line references when reviewing code.
7. If no findings are discovered, say so and list residual risks or untested areas.

## Output Format

Use:

```markdown
## Findings
- [P1] <title> -- <file:line>. <impact and fix direction.>

## Open Questions
- <Only if needed.>

## Residual Risk
- <What was not verified.>
```

For Codex app inline review comments, use the local review directive when appropriate. Keep findings tight and actionable.
