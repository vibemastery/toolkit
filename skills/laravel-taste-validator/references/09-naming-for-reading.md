# Principle 9: Name Things for Reading, Not Writing

## Summary

Methods should read like English. Boolean methods use `is/has/can/should/was`. Action methods use imperative verbs. Scopes read as adjectives or prepositional phrases.

## What to Validate

### 1. Boolean methods start with `is`, `has`, `can`, `should`, `was`
```php
// CORRECT: reads naturally in conditions
$project->isArchived()
$translation->hasBeenReviewed()
$user->canAccessProject($project)
$file->wasModifiedSince($timestamp)
$subscription->shouldRenew()

// VIOLATION: ambiguous — is this a scope, a boolean, or an action?
$project->archived()     // getter? scope? action?
$translation->reviewed() // state check? past action? scope?
$user->access()          // noun? verb?
```

### 2. Action methods are imperative verbs
```php
// CORRECT: imperative verb — clear command
$project->archive()
$translation->approve()
$file->importInto($project)
$subscription->cancel()

// VIOLATION: noun or ambiguous
$project->archival()
$translation->approval()
```

### 3. Scopes read as adjectives or prepositional phrases
```php
// CORRECT: reads naturally after ->
Project::query()->archived()->forTeam($team)->get()
Translation::query()->pending()->inLanguage('fr')->get()
Order::query()->placedAfter($date)->forCustomer($customer)->get()

// VIOLATION: verb-prefixed scopes read awkwardly in chains
Project::query()->getArchived()->filterByTeam($team)->get()
Translation::query()->fetchPending()->whereLanguageIs('fr')->get()
```

### 4. No ambiguous method names
Ambiguity arises when a method could be a:
- Boolean getter: `$post->published()`
- Scope: `Post::query()->published()`
- Action: `$post->published()` (marks as published)

Resolve by:
- Boolean: `isPublished()`
- Scope: `->published()` (scopes are acceptable as adjectives)
- Action: `publish()`

### 5. Parameters named for intent, not type
```php
// VIOLATION: type-named parameters
public function filter(string $s, bool $b): Collection { ... }

// CORRECT: intent-named parameters
public function filter(string $searchTerm, bool $includeArchived): Collection { ... }
```

## Red Flags
- Boolean methods not starting with `is`, `has`, `can`, `should`, `was`
- Scope methods starting with `get`, `fetch`, `find`, `where` (reads awkwardly in chains)
- Action methods using nouns instead of verbs
- Method names that could be confused for multiple types (boolean, scope, or action)
- Abbreviated or cryptic parameter names (`$s`, `$t`, `$dt`)

## Validation Questions for the Architect
1. Do all boolean-returning methods start with `is`, `has`, `can`, `should`, or `was`?
2. Do all query scopes read as adjectives or prepositional phrases (not verb-prefixed)?
3. Are there any method names that are ambiguous between being a boolean check, a scope, or an action?
4. Do all parameters use descriptive, intent-expressing names?
