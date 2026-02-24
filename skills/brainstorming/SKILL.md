---
name: brainstorming
description: "Beginner-first idea-to-plan workflow for Laravel projects. Use before writing implementation code when the user wants to brainstorm features, shape requirements, compare options, validate architecture, and create a reviewed high-level plan for writing-plans."
---

# VibeMastery Brainstorming

Turn rough ideas into a clear, beginner-friendly high-level plan.

## Hard Rules

1. Do not write implementation code during this skill.
2. Do not commit changes. The user must review everything first.
3. Ask one question at a time when clarification is needed.

## Goals

1. Understand what the user wants to build and why.
2. Explain choices in simple terms for beginners.
3. Validate the design with Laravel specialist agents.
4. Produce a high-level plan doc in a user-approved location.
5. Handoff to `writing-plans` for detailed implementation planning.

## Workflow

1. Explore project context (files, existing patterns, constraints).
2. Clarify the idea with short, plain-English questions.
3. Propose 2-3 implementation approaches with trade-offs.
4. Recommend one approach and explain why it is best.
5. Validate the design using the Laravel agents in `agents/`:
   - `laravel-architect.md` for framework design quality
   - `laravel-security-reviewer.md` for security risks
   - `pest-tdd-expert.md` for test strategy
   - `pest-browser-testing.md` for browser/E2E coverage when UI is involved
6. Merge agent feedback, then present the refined design.
7. Ask where to save the plan before writing any plan file.
8. Write the approved high-level plan doc.
9. Invoke `writing-plans` to generate the detailed implementation plan.

## Ask This Before Saving

Use this exact question:

"Where should I save your plan file? Press Enter for `docs/plans/`, or share another folder/path."

If the user presses Enter, default to `docs/plans/`.

Suggested filename format:

`YYYY-MM-DD-<topic>-plan.md`

## Output Structure

Always respond using these sections:

- `Idea in simple terms`
- `Options and trade-offs`
- `Recommended approach`
- `Workflow and why`
- `Validation feedback`
- `Plan file path`
- `Next step`

## Beginner Explanation Standard

- Use simple language, short sentences, and concrete examples.
- Avoid jargon when possible. If needed, define it in one line.
- Explain both what to do and why it matters.
- Keep each section concise and practical.

## Validation Standard

Before finalizing the plan:

1. Run design checks with relevant agents from `agents/`.
2. Capture only actionable findings.
3. Resolve conflicts by prioritizing:
   1) security,
   2) correctness,
   3) maintainability,
   4) speed of delivery.
4. Re-explain updates in beginner terms.

## Completion Criteria

The brainstorming session is complete only when:

1. The user approves the recommended approach.
2. The plan has been validated with the relevant Laravel agents.
3. The plan is saved to a user-approved location.
4. The `writing-plans` skill has been invoked.
5. No commit has been created.

## Mandatory Handoff

After saving the high-level plan, immediately hand off to `writing-plans`.

- Announce: "I am now using `writing-plans` to produce the step-by-step implementation plan."
- Pass the approved scope, constraints, and validation feedback.
- Keep the beginner-first tone.
- Do not start coding.
