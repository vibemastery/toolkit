# Principle 8: Use Events for Cross-Cutting Concerns

## Summary

Fire events at meaningful domain moments. Use observers for model lifecycle side effects. Don't overuse events — primary business logic should not live in listeners.

## What to Validate

### 1. Events fire at meaningful domain moments
```php
// CORRECT: declarative event dispatch via model
class Project extends Model
{
    protected $dispatchesEvents = [
        'created' => ProjectCreated::class,
        'deleted' => ProjectDeleted::class,
    ];
}

// Also acceptable: explicit dispatch in action classes
class ArchiveProject
{
    public function execute(Project $project): void
    {
        $project->update(['archived_at' => now()]);
        event(new ProjectArchived($project));
    }
}
```

### 2. Listeners handle side effects, not primary logic
Appropriate uses of listeners:
- Sending notifications
- Syncing to external services
- Clearing/warming caches
- Writing audit logs
- Updating search indexes

NOT appropriate in listeners:
- Core business logic that makes the feature work
- Database writes that are central to the operation (not a side effect)

### 3. Test: "If I remove this listener, does the feature break?"
```
Feature breaks → logic should NOT be in a listener
Feature works, side effect missing → listener is correct placement
```

### 4. Observers for model lifecycle side effects
```php
// CORRECT: observer for lifecycle side effects
class ProjectObserver
{
    public function creating(Project $project): void
    {
        $project->slug ??= Str::slug($project->name);
    }
}

// VIOLATION: logic embedded in model's boot() when observer is more appropriate
class Project extends Model
{
    protected static function boot(): void
    {
        parent::boot();
        static::creating(function (Project $project) {
            $project->slug ??= Str::slug($project->name);
            // + 20 more lines of logic
        });
    }
}
```

### 5. Events don't add indirection to primary flows
Events are appropriate when a domain moment has **multiple independent consumers**. If only one listener responds to an event, consider whether a direct method call is clearer.

## Red Flags
- Listeners that contain the primary business logic (removing them breaks the feature)
- Long `boot()` methods with model lifecycle logic that belongs in observers
- Events with a single listener that's always fired (direct call may be clearer)
- Side effects (notifications, cache clearing) embedded directly in models or controllers
- No events fired for important domain moments (ProjectCreated, UserRegistered, OrderPlaced)

## Validation Questions for the Architect
1. Does removing any listener break a feature? If yes, the logic should move out of the listener.
2. Are side effects (notifications, cache, syncing) handled by listeners rather than embedded in controllers/models?
3. Are model lifecycle side effects in observers rather than `boot()` closures?
4. Are events firing at the right granularity — meaningful domain moments, not every save?
