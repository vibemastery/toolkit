# Principle 6: Accept Multiple Input Types Where Intent is Unambiguous

## Summary

Follow the `valueRetriever` pattern: accept closures alongside simple types when the operation is obvious. Accept models and IDs interchangeably when the intent is clear. Don't overdo it — use separate methods when disambiguation requires branching.

## What to Validate

### 1. Callback/closure flexibility
```php
// CORRECT: accepts both a closure and a shorthand string
public function groupByLanguage(string|Closure $key = 'language_code'): Collection
{
    return $this->translations->groupBy($key);
}

// USAGE:
$grouped = $importer->groupByLanguage();                      // uses 'language_code'
$grouped = $importer->groupByLanguage('locale');              // uses 'locale'
$grouped = $importer->groupByLanguage(fn($t) => $t->locale); // uses closure
```

### 2. Models and IDs interchangeable
```php
// CORRECT: resolves ambiguity for the caller
public function assignTo(User|int $user): void
{
    $this->update(['user_id' => $user instanceof User ? $user->id : $user]);
}

// VIOLATION: forces caller to always resolve the model
public function assignTo(int $userId): void
{
    $this->update(['user_id' => $userId]);
}
// Caller: $task->assignTo($user->id); // redundant model->id resolution everywhere
```

### 3. When NOT to use polymorphic signatures
```php
// VIOLATION: complex disambiguation — use separate methods instead
public function process(string|array|Collection|Model $input): Result
{
    if (is_string($input)) {
        // one path
    } elseif (is_array($input)) {
        // another path
    } elseif ($input instanceof Collection) {
        // yet another
    }
    // ...
}

// CORRECT: separate methods when types need different logic
public function processPath(string $path): Result { ... }
public function processRecords(Collection $records): Result { ... }
```

### 4. The test: is the intent unambiguous?
Polymorphic signatures are only appropriate when **all accepted types produce the same semantic result** through the same logical path.

## Red Flags
- Methods that always require `$model->id` as the argument when they could accept the model directly
- Polymorphic methods with complex `instanceof` / `is_*` branching chains
- Callback-accepting methods that don't also accept a simple string property name when appropriate

## Validation Questions for the Architect
1. Are there methods that require callers to extract `->id` from a model when they could accept the model itself?
2. Are there methods that accept closures but could also accept a simple string shorthand?
3. Are there polymorphic signatures where the different types actually require fundamentally different logic? Should those be separate methods?
