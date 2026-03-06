# Principle 11: Write Helpers for Repeated Patterns

## Summary

Identify 3-line patterns that appear in 3+ places. Prefer Eloquent casts and accessors for model data transformations. Keep helpers as pure functions — no side effects, no dependencies on database or HTTP.

## What to Validate

### 1. Repeated 3-line patterns extracted
```php
// VIOLATION: same pattern repeated in multiple places
$metadata = $model->metadata ? json_decode($model->metadata, true) : [];

// CORRECT: use a cast instead
protected function casts(): array
{
    return ['metadata' => 'array'];
}
```

The threshold: if the **same pattern** appears **3+ times**, it should be extracted. One-off patterns don't need helpers.

### 2. Casts and accessors preferred for model data transformations
```php
// VIOLATION: helper function for model data
function getProjectStatus(Project $project): string
{
    return match($project->status) {
        'active' => 'Active',
        'archived' => 'Archived',
        default => 'Unknown',
    };
}

// CORRECT: accessor on the model
protected function statusLabel(): Attribute
{
    return Attribute::make(
        get: fn (mixed $value, array $attributes) => match($attributes['status']) {
            'active' => 'Active',
            'archived' => 'Archived',
            default => 'Unknown',
        }
    );
}
```

### 3. Helpers are pure functions
```php
// VIOLATION: helper that needs a database connection (this is a service, not a helper)
function getDefaultProject(User $user): Project
{
    return Project::where('user_id', $user->id)->first();
}

// CORRECT: pure helper — same input, same output, no side effects
function formatTranslationKey(string $key): string
{
    return Str::lower(str_replace([' ', '-'], '_', $key));
}
```

### 4. No premature abstraction
Don't create a helper for a pattern that appears only once or twice. Wait until the third occurrence. The duplication is cheaper than a premature abstraction.

## Red Flags
- Repeated `json_decode($model->field, true) ?: []` patterns (use `'array'` cast)
- Date formatting helpers operating on model fields (use `'datetime'` cast or accessor)
- Global helpers that require `DB::` or `Http::` (these are services)
- Helper functions wrapping a single Laravel call (unnecessary abstraction)
- Pattern appears in only 1-2 places (not yet worth extracting)

## Validation Questions for the Architect
1. Are there data transformation patterns on models that repeat 3+ times and aren't using casts or accessors?
2. Do all project-level helpers qualify as pure functions (no database, no HTTP, no side effects)?
3. Are there single-use helper functions that could be inlined instead?
4. Are date, JSON, or enum transformations on model data handled by Eloquent casts rather than utility functions?
