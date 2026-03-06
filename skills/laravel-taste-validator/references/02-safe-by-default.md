# Principle 2: Safe by Default, Escapable When Needed

## Summary

Validate at system boundaries, trust internally. Name dangerous escape hatches loudly. Whitelist rather than blacklist.

## What to Validate

### 1. Validation at system boundaries only
```php
// CORRECT: FormRequest validates at boundary
class StoreProjectRequest extends FormRequest
{
    public function rules(): array
    {
        return ['name' => ['required', 'string', 'max:255']];
    }
}

// VIOLATION: redundant re-validation inside controller
class ProjectController extends Controller
{
    public function store(StoreProjectRequest $request): RedirectResponse
    {
        if (empty($request->validated()['name'])) { // re-checking what FormRequest guarantees
            abort(422);
        }
        Project::create($request->validated());
    }
}
```

### 2. Dangerous methods named loudly
```php
// VIOLATION: silent bypass
public function archiveSkippingPermissions(): void { ... }

// CORRECT: name shouts danger
public function forceArchive(): void { ... }   // force prefix
public function archiveWithoutChecks(): void { ... }  // without prefix
public function dangerouslyArchive(): void { ... }   // dangerously prefix
```
Acceptable prefixes: `force`, `without`, `dangerously`.

### 3. Fillable over guarded
```php
// VIOLATION: blacklist — new fields are exposed by default
protected $guarded = ['id'];

// CORRECT: whitelist — new fields are locked by default
protected $fillable = ['name', 'description', 'status'];
```

### 4. External data validated aggressively
- API responses parsed through validation or DTOs before use
- File imports / webhook payloads validated at ingestion point
- No raw `json_decode` of external input used directly without shape validation

## Red Flags
- `$guarded = []` or `$guarded = ['id']` on models
- Controllers performing the same validation that FormRequest already handles
- Bypass methods without a loud naming signal (`force*`, `without*`, `dangerously*`)
- External API response data used without shape validation

## Validation Questions for the Architect
1. Are there any re-validation checks inside controllers after FormRequest has already validated?
2. Do all models use `$fillable` (whitelist) rather than `$guarded` (blacklist)?
3. Are there any methods that bypass normal safety checks — and do their names make this obvious?
4. Is external data (API responses, file imports, webhook payloads) validated at the boundary before internal use?
