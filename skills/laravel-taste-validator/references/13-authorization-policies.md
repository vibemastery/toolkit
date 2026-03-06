# Principle 13: Authorization — Policies as the Single Source of Truth

## Summary

Policies hold the rules — always. Route `->can()` for standard CRUD (when auth doesn't need request data). FormRequest `authorize()` when auth needs request body data. Controllers never authorize.

## What to Validate

### 1. Policies contain all authorization rules
```php
// CORRECT: all rules in policy
class ProjectPolicy
{
    public function update(User $user, Project $project): bool
    {
        return $user->hasTeamPermission($project->team, TeamMemberPermission::Project_Update);
    }

    public function delete(User $user, Project $project): bool
    {
        return $user->hasTeamPermission($project->team, TeamMemberPermission::Project_Delete);
    }
}

// VIOLATION: authorization logic outside a policy
class ProjectController extends Controller
{
    public function update(Request $request, Project $project): RedirectResponse
    {
        if ($request->user()->team_id !== $project->team_id) {  // rule outside policy
            abort(403);
        }
    }
}
```

### 2. Route `->can()` for standard CRUD
```php
// CORRECT: authorization declared at route level
Route::put('projects/{project}', UpdateProjectController::class)
    ->can('update', 'project');

Route::delete('projects/{project}', DestroyProjectController::class)
    ->can('delete', 'project');

// VIOLATION: authorization deferred to controller
Route::put('projects/{project}', UpdateProjectController::class); // no ->can()
```

Use route `->can()` when:
- Authorization only needs the authenticated user + route-bound model
- No request body data is required for the authorization decision

### 3. FormRequest `authorize()` when auth needs request data
```php
// CORRECT: FormRequest authorize() when body data is needed
class StoreTranslationRequest extends FormRequest
{
    public function authorize(): bool
    {
        // Needs $this->localeModel from request body — not available at route level
        return $this->user()->can('create', [
            Translation::class,
            $this->project,
            $this->localeModel,
        ]);
    }
}
```

FormRequest `authorize()` **still delegates to the policy** — it doesn't contain rules itself. It's an invocation point only.

### 4. Controllers NEVER call `$this->authorize()`
```php
// VIOLATION: $this->authorize() in controller — easy to forget, not "safe by default"
class ProjectController extends Controller
{
    public function update(Request $request, Project $project): RedirectResponse
    {
        $this->authorize('update', $project);  // someone could delete this line
        // ...
    }
}
```

`$this->authorize()` requires developers to remember to call it. Route `->can()` and FormRequest `authorize()` run automatically — they enforce themselves.

### 5. Decision tree
```
Does auth need request body data?
  ├─ No  → Route ->can() delegating to a Policy
  └─ Yes → FormRequest authorize() delegating to a Policy

Where do the actual rules live?
  └─ Always in a Policy
```

## Red Flags
- `$this->authorize()` anywhere in a controller
- Authorization logic (if checks) in controllers instead of policies
- Routes without `->can()` for protected resources (missing authorization entirely)
- FormRequest `authorize()` containing rules directly (it should delegate to the policy)
- Policy methods not registered (should be auto-discovered via naming convention)
- Manual policy registration in `AuthServiceProvider` when auto-discovery naming applies

## Validation Questions for the Architect
1. Is there any `$this->authorize()` call in any controller? If so, it must be moved to route `->can()` or FormRequest `authorize()`.
2. Does every protected route have `->can()` declared, or is there a FormRequest `authorize()` method?
3. Are all authorization rules in policy classes, not duplicated in controllers or FormRequests?
4. Do FormRequest `authorize()` methods delegate to policies rather than containing the rules themselves?
5. Are policies auto-discovered (named `{Model}Policy`) or manually registered?
