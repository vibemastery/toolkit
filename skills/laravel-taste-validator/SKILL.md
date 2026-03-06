---
name: laravel-taste-validator
description: Validates Laravel application code against 14 "Laravel Taste" principles — the same design philosophy used by the framework itself. Use when the user wants to audit application-layer code quality, asks "does this follow Laravel conventions?", wants architectural feedback on controllers/models/actions/policies, or says "validate my code", "review this against best practices", "apply Laravel taste", or "check my architecture". Runs the vibemastery-toolkit:laravel-architect agent as the validator for each applicable principle.
---

# Laravel Taste Validator

Validates application code against 14 principles that mirror how the Laravel framework itself is designed. For each applicable principle, it delegates to the `vibemastery-toolkit:laravel-architect` agent for expert review.

## Principle Reference Files

Each principle has a dedicated reference file with validation criteria, code examples, red flags, and targeted review questions. Load only the files relevant to the code being reviewed.

| # | File | Covers |
|---|------|--------|
| 1 | [01-convention-eliminates-configuration.md](references/01-convention-eliminates-configuration.md) | Naming, defaults, artisan generators |
| 2 | [02-safe-by-default.md](references/02-safe-by-default.md) | Validation boundaries, loud danger names, `$fillable` vs `$guarded` |
| 3 | [03-closures-for-inline-behavior.md](references/03-closures-for-inline-behavior.md) | One-off query constraints, deferred defaults |
| 4 | [04-fluent-apis.md](references/04-fluent-apis.md) | Chaining, builder vs terminal methods |
| 5 | [05-no-magic-in-application-code.md](references/05-no-magic-in-application-code.md) | No `__call`/`__get`, using framework magic not replicating it |
| 6 | [06-accept-multiple-input-types.md](references/06-accept-multiple-input-types.md) | Models and IDs interchangeable, `valueRetriever` pattern |
| 7 | [07-pipelines.md](references/07-pipelines.md) | Laravel `Pipeline`, single-responsibility steps |
| 8 | [08-events-for-cross-cutting-concerns.md](references/08-events-for-cross-cutting-concerns.md) | Events, observers, don't overuse events |
| 9 | [09-naming-for-reading.md](references/09-naming-for-reading.md) | `is/has/can`, imperative verbs, adjective scopes |
| 10 | [10-composition-over-inheritance.md](references/10-composition-over-inheritance.md) | Traits, action classes, flat controller hierarchy |
| 11 | [11-helpers-for-repeated-patterns.md](references/11-helpers-for-repeated-patterns.md) | Extract at 3 occurrences, casts > helpers, pure functions |
| 12 | [12-thin-controllers.md](references/12-thin-controllers.md) | ≤15 lines, FormRequest, scopes, action classes |
| 13 | [13-authorization-policies.md](references/13-authorization-policies.md) | Policies, route `->can()`, FormRequest `authorize()`, no `$this->authorize()` |
| 14 | [14-test-through-public-api.md](references/14-test-through-public-api.md) | Behavior not internals, factories, descriptive test names |

## Workflow

### Step 1: Identify which principles apply

Based on the files or code shared by the user, identify which of the 14 principles are relevant. You don't need to run all 14 for every review — select those applicable to the code at hand.

**Quick mapping:**
- Controllers → principles 2, 12, 13
- Models → principles 1, 2, 5, 8, 9, 11
- Policies → principle 13
- FormRequests → principles 2, 13
- Routes → principles 1, 13
- Tests → principle 14
- Action classes → principles 7, 10
- Service/utility classes → principles 4, 5, 6, 10, 11
- Query scopes → principles 3, 9

### Step 2: Load relevant principle files and delegate to the architect

For each applicable principle:

1. Read the principle's reference file from `references/`
2. Launch a `vibemastery-toolkit:laravel-architect` agent with this prompt structure:

```
You are validating application code against Laravel Taste Principle #{number}: {title}.

PRINCIPLE CRITERIA:
{paste the full content of the reference file}

CODE TO REVIEW:
{paste the relevant code}

Your task:
- Review the code against the criteria above
- List each VIOLATION with: the file/line, what rule it breaks, and a corrected code example
- List each PASSING check with a brief note
- Rate overall compliance: PASS / NEEDS WORK / FAIL
```

When doing a full audit, dispatch all applicable principle reviews **in parallel** using multiple `vibemastery-toolkit:laravel-architect` agents simultaneously (one per principle), then aggregate results.

### Step 3: Compile and present findings

After all principle reviews complete, present a structured report:

```
## Laravel Taste Validation Report

### Principle 1: Convention Eliminates Configuration — [PASS/NEEDS WORK/FAIL]
[Violations with corrected examples]
[Passing checks]

### Principle 2: Safe by Default — [PASS/NEEDS WORK/FAIL]
...

---
## Summary Checklist

- [ ] Am I repeating what the framework already knows?
- [ ] Is the safe path the easy path?
- [ ] Can I read this method as an English sentence?
- [ ] Is this method doing more than one thing?
- [ ] Would another developer need to read the implementation to understand the interface?
- [ ] Am I building magic or using magic?
- [ ] Does authorization run automatically?
- [ ] Is this tested through the behavior it produces?
```

## Scoped Reviews

For targeted reviews, load only the relevant principles:

| Scenario | Principles to apply |
|----------|---------------------|
| "Review this controller" | 2, 12, 13 |
| "Review this model" | 1, 2, 5, 8, 9, 11 |
| "Review this service/action class" | 4, 5, 6, 7, 10 |
| "Review my tests" | 14 |
| "Review my routes/policies" | 1, 13 |
| Full audit | All 14 |
