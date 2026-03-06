# Principle 1: Convention Eliminates Configuration

## Summary

Name things so the framework can find them. Every override of a convention adds configuration that every future reader must discover and remember.

## What to Validate

### 1. Framework-inferred naming
- Models follow naming conventions: `User`, `Post`, `Comment`
- Policies named `{Model}Policy` (e.g., `UserPolicy` for `User`) — auto-discovered, zero registration
- Foreign keys follow `{model}_id` convention (e.g., `post_id`, `user_id`)
- Relationship method names match model names: `post()`, `comments()`

### 2. No redundant explicit configuration
```php
// VIOLATION: explicit defaults that match convention
class Comment extends Model
{
    public function post(): BelongsTo
    {
        return $this->belongsTo(Post::class, 'post_id', 'id'); // redundant args
    }
}

// CORRECT: let the framework infer
class Comment extends Model
{
    public function post(): BelongsTo
    {
        return $this->belongsTo(Post::class);
    }
}
```

### 3. Sensible defaults in methods
```php
// VIOLATION: forcing caller to state the obvious
public function publish(Carbon $publishedAt): void { ... }

// CORRECT: common case needs zero arguments
public function publish(?Carbon $publishedAt = null): void
{
    $this->update(['published_at' => $publishedAt ?? now()]);
}
```

### 4. Artisan generators used
- No hand-created files that have a generator (`make:model`, `make:controller`, `make:policy`, etc.)
- Generators encode namespace, directory, base class, method stubs

## Red Flags
- `belongsTo(Post::class, 'post_id', 'id')` — explicit defaults
- Custom table names when the plural snake_case convention applies
- Manually registered policies in `AuthServiceProvider` that follow auto-discovery naming
- Required parameters with no default when `null`/`now()` would be the obvious default

## Validation Questions for the Architect
1. Are any relationship definitions specifying arguments that match what the framework would infer by convention?
2. Are any methods requiring arguments that have an obvious default?
3. Are there hand-created files (controllers, models, policies) that should have been generated via `artisan make:`?
4. Are policies manually registered when auto-discovery naming would work?
