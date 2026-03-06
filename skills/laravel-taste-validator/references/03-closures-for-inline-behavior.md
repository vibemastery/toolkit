# Principle 3: Use Closures for Inline Behavior

## Summary

Scope one-off query constraints inline with closures. Reserve named scopes for reusable query fragments. Use closures for deferred defaults.

## What to Validate

### 1. One-off constraints stay inline
```php
// CORRECT: inline closure for a single-use constraint
$posts = Post::query()
    ->with(['comments' => fn ($q) => $q->where('approved', true)->latest()])
    ->get();

// VIOLATION: named scope created for a one-off use
class Comment extends Model
{
    public function scopeApprovedAndLatest($query)  // only used in one place
    {
        return $query->where('approved', true)->latest();
    }
}
```

### 2. Named scopes reserved for reusable fragments
A scope is justified when the same query fragment appears in **3+ places** or represents a stable domain concept (e.g., `->published()`, `->pending()`, `->forTeam($team)`).

### 3. Closures for deferred defaults
```php
// CORRECT: deferred evaluation using null coalescing chain
public function resolveExportFormat(?string $format = null): string
{
    return $format ?? $this->project->default_export_format ?? 'json';
}

// For expensive defaults, accept a closure
public function resolveFormat(string|Closure|null $format = null): string
{
    return value($format) ?? 'json';
}
```

### 4. Closures don't replace abstraction for complex logic
Closures are appropriate for short, readable constraints. If the inline closure exceeds ~5 lines or contains business logic, it should be a named scope or extracted method.

## Red Flags
- Named scopes that only appear in one `->with([])` call or one query
- Complex multi-line closures inline in query builders (extract instead)
- Hardcoded default values that could be deferred or configured

## Validation Questions for the Architect
1. Are there named scopes that are only used in a single location? Should they be inline closures instead?
2. Are any inline closures too complex (>5 lines or containing business rules) to remain inline?
3. Are expensive-to-compute default values evaluated eagerly when they could be deferred?
