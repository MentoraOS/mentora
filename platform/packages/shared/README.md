# @mentora/shared

Pure, reusable utilities and cross-cutting **port contracts**. Depends only on
`@mentora/kernel`. No I/O, no business logic (ADR 0003, family 3).

## What's inside

| Area | Exports |
|------|---------|
| **functional** | `pipe`, `identity`, `constant`, `noop` |
| **collections/array** | `head`, `last`, `chunk`, `unique`, `uniqueBy`, `partition`, `groupBy`, `compact`, `range`, `isEmpty` |
| **collections/object** | `pick`, `omit`, `mapValues`, `isPlainObject` |
| **text** | `isBlank`, `capitalize`, `truncate`, `ensurePrefix`, `ensureSuffix` |
| **numeric** | `clamp`, `sum`, `mean`, `roundTo` |
| **datetime** | `addMillis`, `durationBetweenMillis`, `SECOND_MS`…`DAY_MS`, `Millis` |
| **validation** | `ValidationError`, `requireNonEmptyString`, `requireInRange`, `requireMaxLength` (return `Result`) |
| **resilience** | `RetryPolicy`, `BackoffStrategy`, `computeBackoffMillis`, `shouldRetry` |
| **logging** | `Logger` (port), `LogLevel`, `LogFields`, `noopLogger` |
| **config** | `Config` (port) |

## Design rules

- **Pure and total.** Fallible access returns `Result`/`Option` (from the kernel),
  never `undefined` or a thrown error. Impurity (time, logging, config) is a
  **port**, implemented by an adapter — this package only defines the contracts.
- **Immutable.** Helpers return new values; nothing mutates its input.
- **Not domain.** `ValidationError` is a *technical* failure, not a domain Reason.
  Domain rules live in the domain packages (F3).

## Layout

```
src/
├── index.ts
├── functional/   · collections/  · text/
├── numeric/      · datetime/     · validation/
├── resilience/   · logging/      · config/
```
