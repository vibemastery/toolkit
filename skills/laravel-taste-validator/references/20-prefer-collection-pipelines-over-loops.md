# Principle 20: Prefer Collection Pipelines Over Loops

## Summary

Replace imperative `foreach` loops with expressive collection pipelines using `map`, `filter`, `reduce`, `pluck`, `flatMap`, and other collection methods. Chain operations into readable step-by-step transformations instead of accumulating results in temporary variables.

## What to Validate

### 1. Replace collecting loops with `map` or `pluck`
```php
// VIOLATION: foreach that builds a new array by transforming each item
$names = [];
foreach ($users as $user) {
    $names[] = $user->name;
}

// CORRECT: pluck for simple property extraction
$names = $users->pluck('name');

// VIOLATION: foreach that transforms each item
$receipts = [];
foreach ($orders as $order) {
    $receipts[] = [
        'order_id' => $order->id,
        'total' => $order->total / 100,
        'date' => $order->created_at->format('M j, Y'),
    ];
}

// CORRECT: map for transformations
$receipts = $orders->map(fn ($order) => [
    'order_id' => $order->id,
    'total' => $order->total / 100,
    'date' => $order->created_at->format('M j, Y'),
]);
```

### 2. Replace filtering loops with `filter` or `reject`
```php
// VIOLATION: foreach with conditional to select items
$active = [];
foreach ($users as $user) {
    if ($user->is_active) {
        $active[] = $user;
    }
}

// CORRECT: filter
$active = $users->filter(fn ($user) => $user->is_active);

// Or with higher-order messaging
$active = $users->where('is_active', true);
```

### 3. Replace accumulation loops with `reduce`, `sum`, `count`, etc.
```php
// VIOLATION: foreach that accumulates a value
$total = 0;
foreach ($orders as $order) {
    $total += $order->amount;
}

// CORRECT: sum
$total = $orders->sum('amount');

// CORRECT: reduce for more complex accumulations
$summary = $transactions->reduce(function ($carry, $txn) {
    $carry[$txn->type] = ($carry[$txn->type] ?? 0) + $txn->amount;
    return $carry;
}, []);
```

### 4. Replace nested conditionals with `contains`, `first`, `firstWhere`
```php
// VIOLATION: loop to find a single item
$admin = null;
foreach ($users as $user) {
    if ($user->role === 'admin') {
        $admin = $user;
        break;
    }
}

// CORRECT: first or firstWhere
$admin = $users->firstWhere('role', 'admin');

// VIOLATION: loop to check existence
$hasAdmin = false;
foreach ($users as $user) {
    if ($user->role === 'admin') {
        $hasAdmin = true;
        break;
    }
}

// CORRECT: contains
$hasAdmin = $users->contains('role', 'admin');
```

### 5. Replace switch/if-else chains with lookup tables
```php
// VIOLATION: switch to map a value
$label = match($status) {
    'draft' => 'Draft',
    'published' => 'Published',
    'archived' => 'Archived',
    default => 'Unknown',
};

// CORRECT: lookup table (when the mapping is data, not logic)
$labels = collect([
    'draft' => 'Draft',
    'published' => 'Published',
    'archived' => 'Archived',
])->get($status, 'Unknown');
```

### 6. Chain operations into step-by-step pipelines
```php
// VIOLATION: multiple temporary variables and loops
$activeUsers = [];
foreach ($users as $user) {
    if ($user->is_active) {
        $activeUsers[] = $user;
    }
}
usort($activeUsers, fn ($a, $b) => $a->name <=> $b->name);
$emails = [];
foreach ($activeUsers as $user) {
    $emails[] = $user->email;
}

// CORRECT: chained pipeline that reads as a series of steps
$emails = $users
    ->filter(fn ($user) => $user->is_active)
    ->sortBy('name')
    ->pluck('email');
```

### 7. Use `flatMap` to flatten nested structures
```php
// VIOLATION: nested loop to collect child items
$allComments = [];
foreach ($posts as $post) {
    foreach ($post->comments as $comment) {
        $allComments[] = $comment;
    }
}

// CORRECT: flatMap
$allComments = $posts->flatMap(fn ($post) => $post->comments);
```

### 8. Use `each` only for side effects, never for collecting
```php
// VIOLATION: using each to build a result (use map instead)
$results = [];
$orders->each(function ($order) use (&$results) {
    $results[] = $order->total;
});

// CORRECT: map for transforming, each for side effects
$totals = $orders->map(fn ($order) => $order->total);

// CORRECT use of each: side effects like notifications
$users->each(fn ($user) => $user->notify(new WelcomeNotification));
```

## Red Flags
- `foreach` loops that build a new array by appending (`$items[] = ...`)
- Temporary array variables initialized as `[]` before a loop
- `foreach` with an `if` inside that selects matching items
- `foreach` that accumulates a running total or counter
- Nested `foreach` loops that flatten child collections
- `each` with a `use (&$variable)` reference to collect results
- Multiple sequential loops that could be a single chain

## Validation Questions for the Architect
1. Are there `foreach` loops that could be replaced with `map`, `filter`, `pluck`, `reduce`, or `flatMap`?
2. Are temporary array variables being used to collect results from loops instead of chaining collection methods?
3. Are collection chains readable as step-by-step descriptions of what the code does, or are they overly nested?
4. Is `each` being misused for transformations where `map` would be appropriate?
5. Are there loops exceeding ~10 lines that could be broken into a clear pipeline of named operations?
