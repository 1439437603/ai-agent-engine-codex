---
name: ae:refactor
description: "Plan behavior-preserving cleanup or technical debt reduction for Codex. Trigger on ae:refactor, /ae-refactor, cleanup, refactor, deslop, simplify, or technical debt."
---

# AE Refactor

Use this skill when the user wants cleanup, simplification, restructuring, or technical debt work without changing external behavior.

## Refactor Contract

Before edits, establish:

- Behavior that must remain unchanged.
- Existing tests or minimum regression checks.
- The specific code smell or maintenance problem.
- Files or modules in scope.
- Files or modules out of scope.

## Workflow

1. Read the target code and existing tests.
2. Write a cleanup plan before changing code.
3. Add or identify regression coverage before risky cleanup.
4. Prefer deletion and reuse over new abstractions.
5. Make one smell-focused pass at a time.
6. Run the same verification before and after when practical.
7. Report simplifications made, changed files, evidence, and remaining risks.

## Handoff

For substantial work, produce an `ae:plan`-style plan first. For small safe cleanup, execute through `ae:work` with explicit verification.
