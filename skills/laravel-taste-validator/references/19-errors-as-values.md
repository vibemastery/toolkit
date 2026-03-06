# Principle 19: Treat Errors as Values When Exceptions Add Hidden Control Flow

## Summary

For domain errors that are normal outcomes (not exceptional crashes), return Result objects instead of throwing exceptions. This makes failure paths visible in the method signature and eliminates hidden control flow. Reserve exceptions for truly exceptional situations.

## What to Validate

### 1. Result objects for expected domain failures
```php
// CORRECT: Result object makes failure explicit in the return type
class TransferFunds
{
    public function execute(Account $from, Account $to, Money $amount): Result
    {
        if ($from->balance->lessThan($amount)) {
            return Result::error('Insufficient funds in the source account.');
        }

        if ($from->isFrozen()) {
            return Result::error('The source account is currently frozen.');
        }

        DB::transaction(function () use ($from, $to, $amount) {
            $from->debit($amount);
            $to->credit($amount);
        });

        return Result::ok($from->fresh());
    }
}

// Controller checks the result explicitly
class TransferController extends Controller
{
    public function store(TransferRequest $request, TransferFunds $action): RedirectResponse
    {
        $result = $action->execute(
            $request->fromAccount(),
            $request->toAccount(),
            $request->amount(),
        );

        if ($result->isError()) {
            return back()->with('error', $result->error);
        }

        return redirect()->route('accounts.show', $result->value);
    }
}
```

### 2. Simple Result object implementation
```php
// A minimal Result class — no over-engineering needed
readonly class Result
{
    private function __construct(
        public bool $ok,
        public mixed $value = null,
        public ?string $error = null,
    ) {}

    public static function ok(mixed $value = null): static
    {
        return new static(ok: true, value: $value);
    }

    public static function error(string $message): static
    {
        return new static(ok: false, error: $message);
    }

    public function isOk(): bool
    {
        return $this->ok;
    }

    public function isError(): bool
    {
        return ! $this->ok;
    }
}
```

### 3. Choose the right tool for the failure type
```
Truly exceptional (system crash, bug)     -> throw Exception
Expected domain failure (insufficient     -> return Result::error()
  balance, duplicate submission)
User did something wrong (bad input)      -> FormRequest validation
```

### 4. Don't use both patterns for the same failure
```php
// VIOLATION: mixing exceptions and result objects in the same action
class CancelOrder
{
    public function execute(Order $order): Result
    {
        if ($order->status === OrderStatus::Shipped) {
            throw new OrderAlreadyShippedException($order); // exception
        }

        if ($order->isPastCancellationWindow()) {
            return Result::error('Cancellation window has passed.'); // result
        }
    }
}

// CORRECT: pick one pattern per action class and be consistent
```

## Red Flags
- Actions that throw exceptions for normal, expected domain failures (not bugs or crashes)
- Controllers wrapped in try-catch blocks to handle expected business outcomes
- No way to tell from a method's signature that it can fail — failure is hidden inside thrown exceptions
- Mixing Result returns and thrown exceptions in the same action for similar failure types
- Over-engineered Result classes with monadic chaining when a simple ok/error is sufficient

## Validation Questions for the Architect
1. Are expected domain failures (insufficient balance, duplicate entry, window expired) returned as Result objects rather than thrown as exceptions?
2. Is the failure path visible from the method's return type, or hidden behind thrown exceptions?
3. Is each action class consistent — using either Result objects or exceptions, not both for similar failures?
4. Are exceptions reserved for truly exceptional situations (bugs, infrastructure failures)?
5. Is the Result implementation minimal and fit-for-purpose, not over-engineered?
