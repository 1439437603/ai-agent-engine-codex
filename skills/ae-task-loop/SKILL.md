---
name: ae:task-loop
description: "Iteratively execute a concrete Codex task until validation passes or a real blocker is reached. Trigger on ae:task-loop, /ae-task-loop, keep fixing, loop until green, or continue until verified."
---

# AE Task Loop

Use this skill for bounded fix-and-verify loops such as fixing build errors, type errors, failing tests, or a clearly defined bug.

## Loop

1. State the target and the validation command or scenario.
2. Run the current validation first when safe.
3. Classify the failure: build, type, test, runtime, environment, data, or unclear requirement.
4. Make the smallest targeted fix.
5. Re-run validation and read output.
6. Repeat until validation passes or no meaningful recovery path remains.

## Stop Conditions

Stop only when:

- The validation passes.
- The user cancels.
- A real blocker remains, such as missing credentials, unavailable service, destructive decision, or contradictory requirements.

## Final Report

Include:

- Target
- Iterations performed
- Fixes made
- Verification command and result
- Remaining risks
