# Principle 4: Write Fluent APIs for Domain Objects

## Summary

Return `$this` from mutation methods to enable chaining. Clearly distinguish builder methods (return `$this`) from terminal methods (return a result).

## What to Validate

### 1. Builder methods return `$this` or `static`
```php
// CORRECT: fluent builder
class TranslationImporter
{
    public function from(string $path): static
    {
        $this->path = $path;
        return $this;
    }

    public function into(Project $project): static
    {
        $this->project = $project;
        return $this;
    }
}

// VIOLATION: builder that returns void, breaking the chain
public function from(string $path): void
{
    $this->path = $path;
}
```

### 2. Terminal methods return a meaningful result
```php
// CORRECT: terminal breaks chain, returns result
public function import(): ImportResult
{
    // executes and returns result — NOT $this
}

// VIOLATION: terminal returning $this (misleads callers into chaining further)
public function import(): static
{
    // executes work
    return $this; // wrong — execution is done
}
```

### 3. Chains read as sentences
```php
// CORRECT: reads as an English sentence
$result = $importer->from($path)->into($project)->withStrategy($strategy)->import();

// VIOLATION: no fluency — caller must track intermediate state
$importer->setPath($path);
$importer->setProject($project);
$importer->setStrategy($strategy);
$result = $importer->import();
```

### 4. Builder vs terminal clearly delineated
- Builder methods: `from()`, `into()`, `with*()`, `for*()`, `using*()`
- Terminal methods: `import()`, `execute()`, `run()`, `save()`, `get()`, `all()`

## Red Flags
- Mutation methods that return `void` when they could return `$this`
- Terminal methods that return `$this`
- Classes with many `set*` methods that don't chain
- Methods that both mutate state AND return a result (ambiguous builder/terminal)

## Validation Questions for the Architect
1. Do all mutation-only methods return `$this` or `static` to enable chaining?
2. Are terminal methods clearly identifiable — do they return a result (not `$this`)?
3. Do fluent chains read naturally as English sentences?
4. Is there a clear contract between "builder" methods and "terminal" methods in fluent classes?
