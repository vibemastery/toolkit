---
name: validate
description: "Validate or review any artifact — design documents, code, plans, architecture — using available specialist sub-agents. Use when the user says 'validate this', 'review this', 'check this', or wants expert feedback on something they've produced. General-purpose: works with whatever agents are available."
---

# Validate

Run specialist sub-agents to validate or review whatever the user provides.

## Hard Rules

1. Do not modify the artifact being validated. Only report findings.
2. Ask the user what they want validated if it is not clear.
3. Present findings in beginner-friendly language.

## Available Agents

Use whichever agents are relevant to the user's request:

- `laravel-architect` — framework design, architecture, Laravel conventions
- `laravel-security-reviewer` — security risks, OWASP vulnerabilities
- `pest-tdd-expert` — test strategy, coverage, test quality
- `pest-browser-testing` — browser/E2E test coverage for UI features

If an agent is not available, skip it and note that in the output.

## Workflow

1. Ask the user what they want validated (a file, a plan, a piece of code, etc.) and what kind of feedback they are looking for — unless both are already clear from context.
2. Determine which agents are relevant to the request.
3. Dispatch relevant agents in parallel. Pass each agent the artifact and a clear instruction of what to review.
4. Collect findings from all agents.
5. Merge and deduplicate findings. When agents conflict, prioritize: 1) security, 2) correctness, 3) maintainability, 4) simplicity.
6. Present a single consolidated report to the user.

## Output Format

Present findings grouped by agent, then a merged summary:

### Per-agent section

- **Agent name**
- Findings as a bulleted list, each with severity (Critical / High / Medium / Low)
- If no issues found, say so

### Merged Summary

- Consolidated list of actionable items, ordered by priority
- Conflicting recommendations resolved with reasoning
- All findings explained in plain language

## Completion Criteria

1. All relevant agents have been dispatched and returned.
2. A single consolidated report has been presented.
3. No changes have been made to the validated artifact.
