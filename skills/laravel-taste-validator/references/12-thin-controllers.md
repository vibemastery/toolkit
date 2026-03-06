# Principle 12: Keep Controllers Thin

## Summary

Controllers are routing glue. They authorize (implicitly via route or FormRequest), validate (via FormRequest), call domain logic, and return a response. Nothing more.

## What to Validate

### 1. Controller methods are 15 lines or fewer
```php
// CORRECT: thin controller — orchestrate, don't implement
class ProjectController extends Controller
{
    public function store(StoreProjectRequest $request): RedirectResponse
    {
        $project = Project::create($request->validated());
        return redirect()->route('projects.show', $project);
    }

    public function update(UpdateProjectRequest $request, Project $project): RedirectResponse
    {
        $project->update($request->validated());
        return redirect()->route('projects.show', $project);
    }
}

// VIOLATION: fat controller
class ProjectController extends Controller
{
    public function store(Request $request): RedirectResponse
    {
        // Inline validation (should be FormRequest)
        $validated = $request->validate(['name' => 'required|string']);

        // Business logic (should be in model/action)
        $slug = Str::slug($validated['name']);
        $existing = Project::where('slug', $slug)->count();
        if ($existing > 0) {
            $slug .= '-' . ($existing + 1);
        }

        // Query logic (should be in scope)
        $teamProjects = Project::where('team_id', auth()->user()->team_id)
            ->where('status', 'active')
            ->orderBy('created_at')
            ->get();

        // ... 30 more lines
    }
}
```

### 2. Validation in FormRequest, not inline
```php
// VIOLATION: inline validation in controller
$validated = $request->validate(['name' => 'required|string|max:255']);

// CORRECT: FormRequest handles validation
class StoreProjectRequest extends FormRequest
{
    public function rules(): array { return ['name' => ['required', 'string', 'max:255']]; }
}
```

### 3. Query logic in scopes, not controllers
```php
// VIOLATION: query logic in controller
$projects = Project::where('team_id', $team->id)
    ->where('status', 'active')
    ->orderBy('name')
    ->get();

// CORRECT: named scope
$projects = Project::query()->forTeam($team)->active()->orderByName()->get();
```

### 4. Business logic in actions or models
```php
// VIOLATION: business logic in controller
public function archive(Project $project): RedirectResponse
{
    $project->translations()->update(['status' => 'frozen']);
    $project->update(['archived_at' => now()]);
    Cache::forget("project-{$project->id}");
    Mail::to($project->owner)->send(new ProjectArchivedNotification($project));
    return redirect()->route('projects.index');
}

// CORRECT: action class holds the logic
public function archive(Project $project, ArchiveProject $action): RedirectResponse
{
    $action->execute($project);
    return redirect()->route('projects.index');
}
```

### 5. Response formatting in API Resources
```php
// VIOLATION: inline response shaping in controller
return response()->json([
    'id' => $project->id,
    'name' => $project->name,
    'status' => $project->status,
    // ...
]);

// CORRECT: API Resource
return new ProjectResource($project);
```

## Red Flags
- Controller methods exceeding 15 lines
- `$request->validate([...])` inline in a controller (should be FormRequest)
- Raw Eloquent queries in controllers with multiple `->where()` chains
- Business logic (multiple model updates, cache clearing, mail sending) inline in a controller
- `response()->json(['field' => $model->field, ...])` without an API Resource

## Validation Questions for the Architect
1. Do any controller methods exceed 15 lines?
2. Is there any inline `$request->validate()` that should be a FormRequest?
3. Is there query logic in controllers that should be extracted to scopes?
4. Is there multi-step business logic in controllers that should be in action classes?
5. Are API responses shaped inline in controllers rather than using API Resources?
