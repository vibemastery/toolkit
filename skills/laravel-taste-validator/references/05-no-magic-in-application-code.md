# Principle 5: Keep Magic Out of Application Code

## Summary

The framework earns its magic through exhaustive testing and universal familiarity. Application code does not have that luxury. Use the framework's magic; don't build your own.

## What to Validate

### 1. No `__call` or `__get` in application classes
```php
// VIOLATION: magic in application code
class UserRepository
{
    public function __call($method, $parameters)
    {
        if (str_starts_with($method, 'findBy')) {
            return $this->findByField(Str::snake(substr($method, 6)), ...$parameters);
        }
    }
}

// CORRECT: explicit, searchable, IDE-friendly
class UserRepository
{
    public function findByEmail(string $email): ?User
    {
        return User::where('email', $email)->first();
    }

    public function findBySlug(string $slug): ?User
    {
        return User::where('slug', $slug)->first();
    }
}
```

### 2. No custom dynamic property resolution
- `__get` in application classes creates invisible APIs
- Properties should be explicit on the class or use Eloquent's built-in accessor system

### 3. Framework magic is fine — replicating it is not
**Acceptable framework magic (use freely):**
- Eloquent attribute accessors/mutators (`get*Attribute`, `set*Attribute`, or new-style `Attribute::make()`)
- Eloquent scopes (`scope*` methods)
- Eloquent relationships (`hasMany`, `belongsTo`, etc.)
- Eloquent casts (`casts()` method)
- Laravel magic container bindings
- Facade magic

**Not acceptable in application code:**
- Custom `__call` DSLs
- Custom `__get` property magic
- Dynamic method dispatch

### 4. Stack traces remain useful
Magic methods make stack traces unreadable. Every application method should be findable by searching the codebase.

## Red Flags
- `__call` method in any application class (non-framework, non-vendor code)
- `__get` / `__set` in application classes
- Dynamic method dispatch using `call_user_func` or `$this->$method()`
- Methods that exist only to forward to dynamic `__call`

## Validation Questions for the Architect
1. Are there any `__call` or `__get` methods in application classes (outside vendor/framework)?
2. Are all callable methods on application classes explicitly defined and searchable?
3. Is there any custom dynamic dispatch that could be replaced with explicit methods?
4. Could an IDE find all the methods available on each application class without running the code?
