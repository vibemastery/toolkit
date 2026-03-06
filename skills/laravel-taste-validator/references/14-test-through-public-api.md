# Principle 14: Test Through the Public API

## Summary

Test behavior, not implementation. Assert what the user sees and experiences, not internal state. Use factories for all test data — never raw attribute arrays.

## What to Validate

### 1. Tests verify observable behavior
```php
// CORRECT: tests what the user sees
test('archiving a project hides it from the dashboard', function () {
    $project = Project::factory()->create();

    $project->archive();

    $this->actingAs($project->owner)
        ->get(route('dashboard'))
        ->assertDontSee($project->name);
});

// VIOLATION: tests internal state
test('archive sets archived_at', function () {
    $project = Project::factory()->create();
    $project->archive();
    expect($project->archived_at)->not->toBeNull();  // brittle — breaks if column renamed
});
```

The second test breaks if `archived_at` is renamed. The first test is stable — it verifies the feature works.

### 2. Factories for all test data
```php
// CORRECT: factory with states
$user = User::factory()->admin()->create();
$project = Project::factory()->for($user)->archived()->create();

// VIOLATION: raw attribute array
$project = Project::create([
    'name' => 'Test Project',
    'user_id' => 1,
    'archived_at' => now(),
    // missing required fields? schema change breaks this
]);
```

Factories:
- Encode valid model state
- Resist schema changes (adding a required column breaks `Project::create([])` but not `Project::factory()->create()`)
- Support states (`->archived()`, `->published()`, `->admin()`)

### 3. Check for existing factory states before manually setting attributes
```php
// VIOLATION: manually setting what a factory state already provides
$project = Project::factory()->create(['archived_at' => now()]);

// CORRECT: use the factory state
$project = Project::factory()->archived()->create();
```

### 4. HTTP tests over unit tests for web behavior
```php
// CORRECT: HTTP test verifies the full stack
test('guests cannot view project details', function () {
    $project = Project::factory()->create();
    $this->get(route('projects.show', $project))->assertRedirect(route('login'));
});

// LESS VALUABLE for web behavior: unit-testing the policy in isolation
// (The HTTP test proves the policy is actually enforced, not just that the policy logic is correct)
```

### 5. Testing naming conventions
- Test names describe behavior: `'archiving a project hides it from the dashboard'`
- Not: `'test archive method'` or `'archive_sets_archived_at'`
- Sentence form: reads as a specification

## Red Flags
- Tests asserting on internal state (`->archived_at`, `->status`) when behavior could be tested instead
- Raw `Model::create([...])` in tests instead of `Model::factory()->create()`
- Test names that describe implementation (`'test_status_field_is_set'`) rather than behavior
- No factory states — every test manually sets attributes that factories could encapsulate
- Feature tests that mock so many things they don't actually test integration

## Validation Questions for the Architect
1. Do tests primarily assert on observable behavior (HTTP responses, visible content, redirects) rather than internal model state?
2. Is all test data created via factories rather than raw attribute arrays or `Model::create()`?
3. Do factory states cover the common test scenarios so attributes don't need to be manually set?
4. Do test names read as behavior descriptions (specifications) rather than implementation details?
5. Are there any tests that would survive renaming a database column? (If not, they may be testing internals.)
