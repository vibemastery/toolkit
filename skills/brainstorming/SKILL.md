---
name: brainstorming
description: "Beginner-first idea exploration and design. Use when the user wants to brainstorm features, shape requirements, compare options, and produce a design document. Works for any project or topic. The final output is a saved design doc — no validation, no implementation planning."
---

# Brainstorming

Turn rough ideas into a clear, beginner-friendly design document.

## Hard Rules

1. Do not write implementation code during this skill.
2. Do not commit changes. The user must review everything first.
3. Ask one question at a time.
4. Never work on `main` (or the default branch). Check the current branch at the start — if on `main`, create a feature branch before any file changes.

## Goals

1. Understand what the user wants to build and why.
2. Gather as much context as possible about the problem space.
3. Explain choices in simple terms for beginners.
4. Produce a design document in a user-approved location.

## Workflow

1. Check the current git branch. If on `main` (or the default branch), create and switch to a feature branch named `feature/<short-topic>`. Ask the user to confirm the branch name.
2. Explore project context (files, existing patterns, constraints).
3. Interview the user about every aspect of the idea (see Questioning Standard below). Do not move to step 4 until every branch of the design tree has a clear answer.
4. Propose 2-3 implementation approaches with trade-offs.
5. Recommend one approach and explain why it is best.
6. Ask the user to approve the recommended approach.
7. Ask if they want to save the design document in `docs/plans/` or a different directory.
8. Write the design document using the filename format `YYYY-MM-DD-<topic>-design.md`.
9. Tell the user they can invoke `writing-plans` when they are ready to create a step-by-step implementation plan.

## Questioning Standard

Interview the user about every aspect of the idea until reaching a shared understanding. Be thorough — do not skip branches or accept vague answers. The goal is a complete picture before any design decisions are made.

### Design-tree exploration

Think of the idea as a tree. Each major aspect (who uses it, what it does, how it works, what happens at the edges) is a branch. Each branch has sub-branches (decisions that depend on other decisions).

1. Identify the top-level branches of the design.
2. Walk down one branch at a time. Ask about the most foundational decisions first — ones that other decisions depend on.
3. When a decision on one branch affects another branch, call that out and resolve the dependency before moving on.
4. After completing a branch, briefly summarize what was decided, then move to the next branch.
5. When all branches are explored, summarize the full picture and confirm it with the user before proceeding.

### Challenge-first stance

By default, act as a critical thinking partner — not a yes-man. When the user proposes an idea or direction:

- Push back. Ask why this is the right approach. Present the strongest case against it.
- Surface risks, alternatives, and hidden costs the user may not have considered.
- Do not accept an idea just because the user is enthusiastic. Only move forward when you genuinely have no more arguments against it.
- If the user's reasoning holds up under pressure, say so explicitly and move on.
- If it doesn't, keep pressing until the idea is refined or the user decides to pivot.

This is not about being difficult — it is about making sure the final design is battle-tested before any code is written.

### Questioning rules

- Ask one question at a time. Never stack multiple questions.
- If the user is unsure or gives a vague answer, help them explore it. Offer 2-3 concrete options with trade-offs so they can pick.
- Only move to the next question once the current one has a clear answer.
- Use simple language and concrete examples when framing questions.
- Be persistent — circle back to gaps or contradictions. Do not move to design proposals while open questions remain.

## Output Structure

The design document must include these sections:

- `Idea in simple terms`
- `Options and trade-offs`
- `Recommended approach`
- `Workflow and why`
- `Next step` — always: "Run `writing-plans` when ready to create the implementation plan."

## Beginner Explanation Standard

- Use simple language, short sentences, and concrete examples.
- Avoid jargon when possible. If needed, define it in one line.
- Explain both what to do and why it matters.
- Keep each section concise and practical.

## Completion Criteria

The brainstorming session is complete only when:

1. The user approves the recommended approach.
2. The design document is saved to a user-approved location.
3. The user has been told they can invoke `writing-plans` when ready.
4. No commit has been created.
