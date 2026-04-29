---
name: ae:lfg
description: "Default AI Agent Engine entry for Codex: drive a request from requirements to plan, work, review, and verified delivery. Trigger on ae:lfg, /ae-lfg, build this, implement a feature, or end-to-end delivery."
---

# AE LFG for Codex

Use this as the main pipeline for feature work, bug fixes, migrations, or multi-step engineering tasks.

## Pipeline

1. **Classify the task**
   - Simple answer: answer directly.
   - Unclear intent: use `ae:brainstorm`.
   - Clear small fix: use `ae:work` with lightweight verification.
   - Multi-step delivery: continue through the full pipeline.
   - Review-only request: use `ae:review`.

2. **Clarify requirements**
   - Inspect local context first.
   - Capture goal, scope, constraints, success criteria, and minimum verification.
   - Create a requirements document for substantial work.

3. **Plan**
   - Use `ae:plan` to produce a decision-complete plan.
   - Ensure the plan includes implementation steps and verification evidence.

4. **Implement**
   - Use `ae:work`.
   - Preserve unrelated changes.
   - Make the smallest viable change.

5. **Review**
   - Use `ae:review` on changed code, plan artifacts, or documents.
   - Fix blocking findings before delivery.

6. **Verify**
   - Run the planned checks.
   - Read the real output.
   - If checks fail, use `ae:task-loop` until pass or blocker.

7. **Deliver**
   - Summarize target, changes, verification, result, risks, and best next step.

## Evidence Gate

Before claiming completion, confirm:

- Required files or artifacts exist.
- Relevant tests/checks ran and output was read.
- No known blocking findings remain.
- Remaining risks are explicit.

## V1 Adaptation Notes

This Codex version uses native file inspection, shell verification, git status, and review output instead of platform-specific runtime tools.
