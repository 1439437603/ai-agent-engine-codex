---
name: ae:brainstorm
description: "Clarify requirements and design direction for AI Agent Engine workflows in Codex. Trigger on ae:brainstorm, /ae-brainstorm, unclear requirements, brainstorming, product scoping, or requirements capture."
---

# AE Brainstorm

Use this skill before planning or implementation when the user's intent, scope, constraints, or success criteria are not yet stable.

## Goal

Turn a rough request into a compact requirements artifact that another agent can plan from without guessing.

## Workflow

1. Restate the goal in one sentence.
2. Inspect local context first when the request mentions an existing repo, file, product, or workflow.
3. Ask only questions that materially change scope, constraints, or success criteria.
4. Prefer concrete options over open-ended questions.
5. Propose 2-3 approaches with tradeoffs and a recommendation.
6. Write the agreed requirements to `docs/ae/brainstorms/YYYY-MM-DD-<topic>-requirements.md` when the task is substantial.
7. Self-review the requirements for placeholders, contradictions, hidden assumptions, and missing verification criteria.

## Required Requirements Shape

Include:

- Goal
- Audience or operator
- In scope
- Out of scope
- Constraints and risks
- Success criteria
- Minimum verification
- Recommended next step

## Handoff

If requirements are clear enough for implementation planning, invoke or recommend `ae:plan` with the requirements path or the summarized request. If the task is simple and already scoped, state that brainstorming is not needed and hand off directly to `ae:work` or a direct answer.
