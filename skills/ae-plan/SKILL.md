---
name: ae:plan
description: "Create a decision-complete implementation plan for Codex. Trigger on ae:plan, /ae-plan, plan this, implementation plan, roadmap plan, or turning requirements into executable steps."
---

# AE Plan

Use this skill to convert clear requirements into a plan that can be implemented without further design decisions.

## Inputs

Accept any of:

- A user request
- A requirements document path
- An existing plan that needs revision
- A bug or refactor description

## Workflow

1. Read relevant repository files and instructions before planning.
2. Define the target outcome and completion criteria.
3. Identify runtime, protocol, state, tool, safety, and integration risks.
4. Choose the smallest implementation that satisfies the goal.
5. Specify public interfaces, file locations, data flow, and failure handling only where needed to prevent ambiguity.
6. Define verification commands and expected evidence.
7. Save substantial plans to `docs/ae/plans/YYYY-MM-DD-<topic>-plan.md` when the user expects a durable artifact.

## Plan Format

Use this structure:

```markdown
# <Title>

## Summary
<What will change and why.>

## Key Changes
- <Behavior-level change>
- <Interface or workflow change>

## Implementation Steps
1. <Concrete step with target files or components>
2. <Concrete step with target files or components>

## Test Plan
- <Command or scenario>
- <Expected evidence>

## Assumptions
- <Default chosen if relevant>
```

## Quality Bar

- The implementer should not need to choose architecture, filenames, public interfaces, or verification strategy.
- Do not over-specify unrelated internals.
- Do not start implementation from this skill unless the user explicitly asks to execute and the current collaboration mode allows it.
