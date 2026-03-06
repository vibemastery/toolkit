# Principle 15: Use the Right Validation Tool for Each Scenario

## Summary

Laravel provides purpose-built validation hooks for every scenario. Pick the narrowest tool that fits: `prepareForValidation` for dirty data, regular rules for single-field checks, `DataAwareRule` for context-dependent single-field rules, and the `after` hook for cross-field conflicts. Stop at `authorize` for permission gates.

## What to Validate

### 1. Dirty input normalized in `prepareForValidation`
```php
// CORRECT: normalize before rules run
class StoreUserRequest extends FormRequest
{
    protected function prepareForValidation(): void
    {
        $this->merge([
            'email' => Str::lower($this->email),
            'phone' => preg_replace('/[\s\-]/', '', $this->phone),
        ]);
    }

    public function rules(): array
    {
        return [
            'email' => ['required', 'email', 'unique:users'],
            'phone' => ['required', 'min:10'],
        ];
    }
}

// VIOLATION: normalizing in the controller after validation
class UserController extends Controller
{
    public function store(StoreUserRequest $request): RedirectResponse
    {
        $data = $request->validated();
        $data['email'] = strtolower($data['email']); // too late — unique rule ran against mixed case
        User::create($data);
    }
}
```

### 2. Context-dependent single-field rules use `DataAwareRule`
```php
// CORRECT: rule that needs context from other submitted fields
use Illuminate\Contracts\Validation\DataAwareRule;
use Illuminate\Contracts\Validation\ValidationRule;

class MaxQuantityForProduct implements ValidationRule, DataAwareRule
{
    protected array $data = [];

    public function setData(array $data): static
    {
        $this->data = $data;

        return $this;
    }

    public function validate(string $attribute, mixed $value, Closure $fail): void
    {
        $product = Product::find($this->data['product_id']);

        if ($product && $value > $product->max_quantity) {
            $fail("Quantity cannot exceed {$product->max_quantity} for this product.");
        }
    }
}

// VIOLATION: checking against other fields inside the controller
public function store(Request $request): RedirectResponse
{
    $product = Product::find($request->product_id);
    if ($request->quantity > $product->max_quantity) {
        return back()->withErrors(['quantity' => 'Too many']);
    }
}
```

### 3. Cross-field conflicts handled in `after`
```php
// CORRECT: after hook for multi-field validation
class StoreBookingRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'start_date' => ['required', 'date'],
            'end_date'   => ['required', 'date', 'after:start_date'],
        ];
    }

    public function after(): array
    {
        return [
            new NoOverlappingBookings,
        ];
    }
}

// Extracted into a reusable invokable class
class NoOverlappingBookings
{
    public function after(Validator $validator): void
    {
        $data = $validator->validated();
        $overlapping = Booking::query()
            ->where('room_id', $data['room_id'])
            ->where('start_date', '<', $data['end_date'])
            ->where('end_date', '>', $data['start_date'])
            ->exists();

        if ($overlapping) {
            $validator->errors()->add('start_date', 'This room is already booked for the selected dates.');
        }
    }
}

// VIOLATION: cross-field database checks in the controller
public function store(StoreBookingRequest $request): RedirectResponse
{
    if (Booking::where('room_id', $request->room_id)
        ->where('start_date', '<', $request->end_date)
        ->where('end_date', '>', $request->start_date)
        ->exists()) {
        return back()->withErrors(['start_date' => 'Overlapping booking']);
    }
}
```

### 4. Permission checks in `authorize`, not rules
```php
// CORRECT: authorization in the FormRequest
class UpdateProjectRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()->can('update', $this->route('project'));
    }
}

// VIOLATION: permission check inside rules or controller
public function rules(): array
{
    if (! auth()->user()->can('update', $this->route('project'))) {
        abort(403); // don't mix authorization with validation
    }
    return ['name' => ['required']];
}
```

### 5. Decision tree applied correctly
```
Data is dirty?                       -> prepareForValidation
Single field invalid on its own?     -> Regular rule
Single field invalid given context?  -> DataAwareRule
Multiple fields conflict?            -> after hook
Is the user allowed to do this?      -> authorize method
```

## Red Flags
- Input normalization (lowercasing, stripping characters) happening after validation rules run
- Database queries for cross-field validation inside controllers instead of `after` hooks
- Large closures inside `after` instead of extracted invokable classes
- Controller methods manually checking one field against another field's related data
- Authorization logic mixed into validation rules

## Validation Questions for the Architect
1. Is any input normalization happening after validation (in controllers or actions) that should use `prepareForValidation`?
2. Are there custom rules that need access to other submitted fields — and do they implement `DataAwareRule`?
3. Are cross-field database checks (overlapping dates, percentages summing to 100) in `after` hooks rather than controllers?
4. Are `after` hook closures kept short, or extracted into invokable classes when they grow?
5. Is authorization handled via `authorize()` / policies rather than mixed into validation rules?
