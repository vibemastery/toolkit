# Principle 17: Design Exceptions with Intention

## Summary

Custom exceptions should be specific, self-rendering, and self-reporting. Use `render()` to let exceptions decide their own HTTP response, `context()` to attach structured log data, and `report()` to control logging severity. This eliminates try-catch blocks in controllers and keeps error handling close to the error's meaning.

## What to Validate

### 1. Custom exceptions are specific and named for intent
```php
// CORRECT: name describes the domain failure
class OrderAlreadyShippedException extends Exception { }
class InsufficientBalanceException extends Exception { }
class BookingOverlapException extends Exception { }

// VIOLATION: generic exceptions with string messages
throw new \RuntimeException('Cannot cancel order');
throw new \Exception('Not enough balance');
throw new \InvalidArgumentException('Booking conflict');
```

### 2. Exceptions attach structured context for logging
```php
// CORRECT: context() provides structured data for logs and error trackers
class OrderAlreadyShippedException extends Exception
{
    public function __construct(
        public readonly Order $order,
    ) {
        parent::__construct("Order #{$order->id} has already been shipped.");
    }

    public function context(): array
    {
        return [
            'order_id' => $this->order->id,
            'status' => $this->order->status->value,
            'shipped_at' => $this->order->shipped_at?->toIso8601String(),
        ];
    }
}

// VIOLATION: unstructured error data — hard to search in logs
throw new \Exception("Order {$order->id} status is {$order->status->value} — cannot cancel");
```

### 3. Exceptions render their own response via `render()`
```php
// CORRECT: exception decides how to present itself
class OrderAlreadyShippedException extends Exception
{
    public function render(Request $request): JsonResponse|RedirectResponse
    {
        if ($request->expectsJson()) {
            return response()->json([
                'message' => 'This order has already been shipped and cannot be cancelled.',
            ], 409);
        }

        return redirect()->back()->with('error', 'This order has already been shipped.');
    }
}

// VIOLATION: try-catch in controller to format the response
class OrderController extends Controller
{
    public function cancel(CancelOrderRequest $request, Order $order, CancelOrder $action): RedirectResponse
    {
        try {
            $action->execute($order, $request->validated('reason'));
        } catch (OrderAlreadyShippedException $e) {
            return back()->with('error', 'Cannot cancel a shipped order.');
        }

        return redirect()->route('orders.show', $order);
    }
}

// CORRECT: controller stays clean — exception handles itself
class OrderController extends Controller
{
    public function cancel(CancelOrderRequest $request, Order $order, CancelOrder $action): RedirectResponse
    {
        $action->execute($order, $request->validated('reason'));

        return redirect()->route('orders.show', $order);
    }
}
```

### 4. Expected exceptions use `report()` to control logging severity
```php
// CORRECT: expected failure logged as info, not error
class DuplicateSubmissionException extends Exception
{
    public function report(): bool
    {
        Log::info('Duplicate form submission detected', $this->context());

        return false; // prevent default error-level logging
    }
}

// CORRECT: opt-out of reporting entirely for noisy but harmless errors
class RateLimitHitException extends Exception
{
    public function report(): bool
    {
        return false; // don't log or report at all
    }
}

// VIOLATION: all exceptions logged at error level by default,
// flooding Sentry/Nightwatch with expected failures
```

### 5. No try-catch in controllers when exceptions self-render
Laravel's exception handler checks for `render()` on the exception automatically (`Handler.php` line 604). When an exception implements `render()`, the controller never needs to catch it — the framework handles the response.

## Red Flags
- Try-catch blocks in controllers that format error responses (the exception should self-render)
- Generic `\Exception` or `\RuntimeException` for domain failures
- String-only error messages with no structured `context()` data
- Expected/harmless exceptions flooding error trackers because `report()` isn't overridden
- Exception classes with no `render()` that force every caller to wrap in try-catch

## Validation Questions for the Architect
1. Are custom exceptions named for their specific domain failure (not generic)?
2. Do exceptions provide structured `context()` arrays for logging?
3. Do domain exceptions implement `render()` to produce their own HTTP response?
4. Are expected/harmless exceptions using `report()` to downgrade or suppress logging?
5. Are controllers free of try-catch blocks for domain exceptions that could self-render?
