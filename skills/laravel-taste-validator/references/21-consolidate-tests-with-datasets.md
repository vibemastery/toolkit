# Principle 21: Consolidate Tests with Datasets

## Summary

When multiple tests share the same structure — setup, action, assertion — but differ only in their input data and expected outcomes, merge them into a single parametrized test with a `->with()` dataset. This eliminates structural duplication, makes the full set of scenarios scannable in one place, and makes adding new cases a one-line change.

## What to Validate

### 1. Identical test bodies with different data should use datasets

```php
// VIOLATION: three tests with identical structure, only data differs
test('returns 200 for admin', function () {
    $user = User::factory()->create(['role' => 'admin']);
    $this->actingAs($user)->get('/dashboard')->assertOk();
});

test('returns 200 for editor', function () {
    $user = User::factory()->create(['role' => 'editor']);
    $this->actingAs($user)->get('/dashboard')->assertOk();
});

test('returns 403 for guest role', function () {
    $user = User::factory()->create(['role' => 'guest']);
    $this->actingAs($user)->get('/dashboard')->assertForbidden();
});

// CORRECT: one parametrized test with a dataset
test('dashboard access by role', function (string $role, int $expectedStatus) {
    $user = User::factory()->create(['role' => $role]);
    $this->actingAs($user)->get('/dashboard')->assertStatus($expectedStatus);
})->with([
    'admin'  => ['role' => 'admin',  'expectedStatus' => 200],
    'editor' => ['role' => 'editor', 'expectedStatus' => 200],
    'guest'  => ['role' => 'guest',  'expectedStatus' => 403],
]);
```

### 2. Tests that vary only in input/output pairs

```php
// VIOLATION: separate tests for each classification
test('exact match classifies as ContentAndPathMatch', function () {
    $key = Key::factory()->create(['path' => 'a']);
    $key->translations()->create(['value' => 'Hello']);
    $incoming = KeyData::from(['name' => 'a', 'value' => 'Hello']);
    $strategy->match($incoming);
    expect($incoming)->matchType->toBe(SegmentMatchType::ContentAndPathMatch);
});

test('different content classifies as NoMatch', function () {
    $key = Key::factory()->create(['path' => 'a']);
    $key->translations()->create(['value' => 'Hello']);
    $incoming = KeyData::from(['name' => 'a', 'value' => 'Changed']);
    $strategy->match($incoming);
    expect($incoming)->matchType->toBe(SegmentMatchType::NoMatch);
});

// CORRECT: consolidated with a dataset
test('classifies incoming key correctly', function (string $existingValue, string $incomingValue, SegmentMatchType $expected) {
    $key = Key::factory()->create(['path' => 'a']);
    $key->translations()->create(['value' => $existingValue]);
    $incoming = KeyData::from(['name' => 'a', 'value' => $incomingValue]);
    $strategy->match($incoming);
    expect($incoming)->matchType->toBe($expected);
})->with([
    'exact match'      => ['existingValue' => 'Hello', 'incomingValue' => 'Hello',   'expected' => SegmentMatchType::ContentAndPathMatch],
    'content differs'  => ['existingValue' => 'Hello', 'incomingValue' => 'Changed', 'expected' => SegmentMatchType::NoMatch],
]);
```

### 3. When NOT to consolidate

Keep tests separate when:
- **Setup differs significantly** — one test creates 3 models and another creates 1; merging would require conditional setup logic, which makes tests harder to read
- **Assertions differ in kind** — one test checks a match type, another checks a side effect like a database write or event dispatch
- **The test name would become vague** — if you can't name the parametrized test clearly, the scenarios are probably testing different behaviors, not variations of one

```php
// KEEP SEPARATE: these test different behaviors despite similar-looking setup
test('duplicate content produces DuplicateContentNoPath', function () {
    // Creates TWO existing keys with the same content — structurally different setup
    Key::factory(2)->createSequence(...)->each(...);
    // ...
});

test('mixed batch: pass 1 matches some keys, pass 2 handles the rest', function () {
    // Creates THREE existing keys and FOUR incoming keys — different scale and intent
    // ...
});
```

### 4. Use named keys in datasets for clarity

```php
// VIOLATION: positional arrays — what does the second 'true' mean?
->with([
    ['admin', '/dashboard', true],
    ['guest', '/dashboard', false],
]);

// CORRECT: named keys make each case self-documenting
->with([
    'admin can access'  => ['role' => 'admin',  'route' => '/dashboard', 'allowed' => true],
    'guest is rejected' => ['role' => 'guest',  'route' => '/dashboard', 'allowed' => false],
]);
```

### 5. Nullable dataset parameters

When some cases need a value and others need null, use nullable types in the test signature rather than conditionally skipping setup.

```php
// CORRECT: nullable parameter, applied uniformly
test('handles optional placeholders', function (string $content, ?array $placeholders, SegmentMatchType $expected) {
    $key = Key::factory()->create(['placeholders' => $placeholders]);
    // ...
})->with([
    'with placeholders'    => ['content' => '...', 'placeholders' => [...], 'expected' => SegmentMatchType::ContentAndPathMatch],
    'without placeholders' => ['content' => '...', 'placeholders' => null,  'expected' => SegmentMatchType::NoMatch],
]);
```

## Red Flags

- Two or more tests where the only difference is the value assigned to a variable
- Tests that were clearly copy-pasted and then had one or two values changed
- A test file where adding a new scenario requires duplicating 10+ lines of setup
- Tests with names like `'test X with value A'` and `'test X with value B'`

## Validation Questions for the Architect

1. Are there groups of tests with identical structure that differ only in their input data and expected outcome?
2. Would merging those tests into a single `->with()` dataset make the scenarios easier to scan and extend?
3. If tests were consolidated, would the parametrized test name still clearly describe the behavior being tested?
4. Are dataset entries named with descriptive keys that explain why each case matters?
5. Are there tests that should stay separate because their setup or assertions are fundamentally different?
