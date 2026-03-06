# Principle 16: Separate Validation from Business Logic

## Summary

Validation answers "is this data well-formed?" Business logic answers "is this action allowed given the system's current state?" Keep them in separate layers: FormRequests validate shape, Action classes enforce business rules via guard clauses and custom exceptions.

## What to Validate

### 1. FormRequests only validate data shape
```php
// CORRECT: FormRequest checks data structure
class CancelOrderRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'reason' => ['required', 'string', 'max:500'],
        ];
    }
}

// VIOLATION: business state check in FormRequest
class CancelOrderRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'reason' => ['required', 'string', 'max:500'],
        ];
    }

    public function authorize(): bool
    {
        // This is a business rule, not authorization
        return $this->route('order')->status !== OrderStatus::Shipped;
    }
}
```

### 2. Business state enforced in Action classes with guard clauses
```php
// CORRECT: Action class checks business state before acting
class CancelOrder
{
    public function execute(Order $order, string $reason): void
    {
        if ($order->status === OrderStatus::Shipped) {
            throw new OrderAlreadyShippedException($order);
        }

        if ($order->status === OrderStatus::Cancelled) {
            throw new OrderAlreadyCancelledException($order);
        }

        $order->update([
            'status' => OrderStatus::Cancelled,
            'cancelled_at' => now(),
            'cancellation_reason' => $reason,
        ]);

        event(new OrderCancelled($order));
    }
}

// VIOLATION: business guards in the controller
class OrderController extends Controller
{
    public function cancel(CancelOrderRequest $request, Order $order): RedirectResponse
    {
        if ($order->status === OrderStatus::Shipped) {
            return back()->with('error', 'Cannot cancel a shipped order.');
        }

        $order->update([
            'status' => OrderStatus::Cancelled,
            'cancelled_at' => now(),
            'cancellation_reason' => $request->validated('reason'),
        ]);

        return redirect()->route('orders.show', $order);
    }
}
```

### 3. Controllers wire request to action — nothing more
```php
// CORRECT: controller is pure wiring
class OrderController extends Controller
{
    public function cancel(CancelOrderRequest $request, Order $order, CancelOrder $action): RedirectResponse
    {
        $action->execute($order, $request->validated('reason'));

        return redirect()->route('orders.show', $order);
    }
}
```

### 4. Action classes throw specific exceptions, not generic ones
```php
// CORRECT: specific, meaningful exception
throw new OrderAlreadyShippedException($order);

// VIOLATION: generic exception with no domain meaning
throw new \RuntimeException('Cannot cancel order');
throw new \Exception('Order already shipped');
```

### 5. The boundary is clear
```
FormRequest           -> "Is the email valid? Is the name present?"
Action guard clause   -> "Has this order already shipped? Is the account frozen?"
Policy / authorize    -> "Is this user allowed to perform this action?"
```

## Red Flags
- Business state checks (`$order->status === 'shipped'`) inside FormRequests
- Guard clauses (`if ($model->isFrozen()) return back()`) inline in controllers
- Generic `\Exception` or `\RuntimeException` thrown for domain-specific failures
- Action classes that re-validate data shape (that's the FormRequest's job)
- Controllers longer than 5-10 lines because business checks are inline

## Validation Questions for the Architect
1. Do FormRequests contain any business state checks beyond data shape validation?
2. Are business rules (state guards, eligibility checks) extracted into Action classes rather than sitting in controllers?
3. Do Action classes throw specific custom exceptions instead of generic ones?
4. Are controllers free of business logic — only wiring FormRequest to Action to Response?
5. Is the `authorize()` method used only for permission checks (policies), not business state?
