# Principle 18: Communicate Errors to Users with Precision

## Summary

Validation errors belong inline next to the offending field. Business logic errors belong in global flash messages or toasts. Custom error messages should tell the user exactly how to fix the problem, not just what went wrong.

## What to Validate

### 1. FormRequest `messages()` are specific and actionable
```php
// CORRECT: tell the user how to fix it
class StoreUserRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'password' => ['required', 'string', 'min:8'],
            'email' => ['required', 'email', 'unique:users'],
        ];
    }

    public function messages(): array
    {
        return [
            'password.min' => 'Your password must be at least 8 characters.',
            'email.unique' => 'An account with this email already exists. Try signing in instead.',
        ];
    }
}

// VIOLATION: relying on Laravel's generic messages
// "The value must be at least 8." — at least 8 what? Which value?
// "The email has already been taken." — taken by whom? What should I do?
```

### 2. Validation errors displayed inline next to fields
```tsx
// CORRECT: inline error next to the field, field highlighted
<div>
    <label htmlFor="email">Email</label>
    <input
        id="email"
        type="email"
        className={errors.email ? 'border-red-500' : 'border-gray-300'}
        value={data.email}
        onChange={(e) => setData('email', e.target.value)}
    />
    {errors.email && (
        <p className="mt-1 text-sm text-red-600">{errors.email}</p>
    )}
</div>

// VIOLATION: errors shown only at the top of the form as a generic list
<div className="alert alert-danger">
    <ul>
        {Object.values(errors).map((error, i) => (
            <li key={i}>{error}</li>
        ))}
    </ul>
</div>
```

### 3. Never clear user input on validation failure
```tsx
// CORRECT: preserve the user's input so they can correct it
<input value={data.email} onChange={(e) => setData('email', e.target.value)} />

// VIOLATION: resetting form state on error
const handleSubmit = () => {
    post(route('users.store'), {
        onError: () => reset(), // user loses everything they typed
    });
};
```

### 4. Business logic errors shown as global flash/toast messages
```php
// CORRECT: self-rendering exception redirects with flash message
class OrderAlreadyShippedException extends Exception
{
    public function render(Request $request): RedirectResponse
    {
        return redirect()->back()->with(
            'error',
            'This order has already been shipped. Contact support if you need help.'
        );
    }
}

// The frontend renders flash messages globally
// {flash.error && <Toast type="error" message={flash.error} />}
```

### 5. Error messages include a clear next step
```php
// CORRECT: actionable messages
'An account with this email already exists. Try signing in instead.'
'This order has already been shipped. Contact support if you need help.'
'Your session has expired. Please refresh the page and try again.'

// VIOLATION: dead-end messages with no guidance
'Email already taken.'
'Cannot cancel order.'
'Session expired.'
```

### 6. Scroll to first error on submission
```tsx
// CORRECT: scroll the user to the first validation error
const handleSubmit = () => {
    post(route('users.store'), {
        onError: () => {
            const firstError = document.querySelector('[data-error]');
            firstError?.scrollIntoView({ behavior: 'smooth', block: 'center' });
        },
    });
};

// VIOLATION: user hits submit, nothing visible changes, errors are off-screen
```

## Red Flags
- Relying entirely on Laravel's default validation messages without customizing via `messages()`
- Validation errors displayed only as a list at the top of the form, not inline next to fields
- Form input cleared on validation failure (user has to re-type everything)
- Business logic errors (not tied to a specific field) shown inline instead of as flash/toast
- Error messages that state the problem without suggesting a fix
- No scroll-to-first-error behavior on form submission

## Validation Questions for the Architect
1. Do FormRequests customize `messages()` for user-facing fields with specific, actionable text?
2. Are validation errors displayed inline next to the relevant field with visual highlighting?
3. Is user input preserved on validation failure (no form reset on error)?
4. Are business logic errors (from exceptions or flash) displayed as global toasts/banners rather than inline field errors?
5. Do error messages tell the user what to do next, not just what went wrong?
6. Does the UI scroll to the first error when a form submission fails?
