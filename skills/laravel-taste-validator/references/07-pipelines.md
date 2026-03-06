# Principle 7: Compose Behavior in Pipelines

## Summary

When data flows through a sequence of transformations, use Laravel's `Pipeline` rather than a chain of method calls. Prefer small, single-responsibility steps that can be reordered, replaced, or reused.

## What to Validate

### 1. Multi-step processing uses `Pipeline`
```php
// CORRECT: Laravel Pipeline for sequential transformations
use Illuminate\Pipeline\Pipeline;

$result = app(Pipeline::class)
    ->send($importedData)
    ->through([
        NormalizeLineEndings::class,
        DetectEncoding::class,
        ParseTranslationKeys::class,
        ValidateStructure::class,
        MergeWithExisting::class,
    ])
    ->thenReturn();

// VIOLATION: long method with phases embedded inline
public function processImport(array $data): Result
{
    // Phase 1: normalize
    $data = str_replace("\r\n", "\n", $data);
    // Phase 2: detect encoding
    // Phase 3: parse
    // ... 50 more lines
}
```

### 2. Each step is an independent class with `handle($data, $next)`
```php
// CORRECT: single-responsibility pipe class
class NormalizeLineEndings
{
    public function handle(array $data, Closure $next): mixed
    {
        $data['content'] = str_replace("\r\n", "\n", $data['content']);
        return $next($data);
    }
}
```

### 3. Steps can be reordered, added, or removed
- No tight coupling between pipeline steps
- Each step only knows its input type and the `$next` closure
- Steps should be individually testable in isolation

### 4. Methods with clearly separable phases should be extracted
Ask: "Can any phase of this method be reused in a different context?" If yes, extract it as a pipeline step or class.

Separable phases that warrant extraction:
- Validation
- Transformation / normalization
- Persistence
- Notification / side effects

## Red Flags
- Methods exceeding 20 lines with multiple distinct "phases" inline
- "Processing" methods that validate AND transform AND persist AND notify
- Long chains of `$data = transform($data)` calls in sequence
- Copy-pasted transformation logic in multiple places (extract to a shared pipeline step)

## Validation Questions for the Architect
1. Are there multi-step processing methods that could be decomposed into a `Pipeline`?
2. Is each pipeline step a single-responsibility class that could be tested in isolation?
3. Are there phases of long methods that are also needed elsewhere (suggesting extraction to reusable pipeline steps)?
4. Are pipeline steps free of coupling to each other (each only depends on the data shape, not other steps)?
