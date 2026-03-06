# Principle 10: Composition Over Inheritance in Application Code

## Summary

Use traits for shared model behavior. Use action classes for reusable operations. Avoid deep inheritance chains — use middleware, traits, and form requests instead.

## What to Validate

### 1. Traits for shared model behavior
```php
// CORRECT: trait with boot hook for shared behavior
trait HasSlug
{
    public static function bootHasSlug(): void
    {
        static::creating(function (Model $model) {
            $model->slug ??= Str::slug($model->{$model->slugSource()});
        });
    }

    abstract public function slugSource(): string;
}

class Project extends Model
{
    use HasSlug;

    public function slugSource(): string { return 'name'; }
}

// VIOLATION: base model class that all models extend
class BaseModel extends Model
{
    protected function generateSlug(): void { ... }
    protected function logActivity(): void { ... }
    protected function syncToSearch(): void { ... }
    // ...every model inherits all of this
}
```

### 2. Action classes for reusable operations
```php
// CORRECT: single-responsibility action class
class ImportTranslationFile
{
    public function execute(Project $project, UploadedFile $file, MergeStrategy $strategy): ImportResult
    {
        // fully testable, reusable from controller/command/job
    }
}

// VIOLATION: base service class with many operations
class TranslationService
{
    public function import(...): ImportResult { ... }
    public function export(...): ExportResult { ... }
    public function validate(...): ValidationResult { ... }
    public function sync(...): void { ... }
    // shared mutable state, unclear responsibility
}
```

Action classes:
- Have a single responsibility (`execute()` or `handle()` method)
- Have a clear interface
- Have no shared mutable state
- Are usable from controllers, console commands, and queued jobs

### 3. No deep inheritance chains
```php
// VIOLATION: deep inheritance
class BaseController extends Controller { ... }
class ApiController extends BaseController { ... }
class AuthenticatedApiController extends ApiController { ... }
class ProjectApiController extends AuthenticatedApiController { ... }

// CORRECT: flat controller + composition
class ProjectController extends Controller
{
    // Authentication: route middleware
    // Authorization: route ->can() or FormRequest
    // Shared behavior: traits
    // Validation: FormRequest
}
```

Maximum inheritance depth: 1 (direct extension of a Laravel framework class).

## Red Flags
- Abstract base controller classes beyond `Controller`
- `BaseModel` or similar base model classes with shared logic that could be traits
- Service classes with more than 5 public methods
- Controllers extending custom controller hierarchies
- Business logic in a base class that applies to "most but not all" subclasses

## Validation Questions for the Architect
1. Is shared model behavior implemented as traits rather than base model classes?
2. Are reusable operations encapsulated in single-responsibility action classes?
3. Are there inheritance chains deeper than 1 level (beyond the framework base class)?
4. Do action classes have no shared mutable state and a single `execute()`/`handle()` method?
5. Are service classes focused enough to have fewer than 5 public methods? If not, should they be split into action classes?
