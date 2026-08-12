# @mentora/contracts

Technical, cross-cutting **contracts** — interfaces, DI tokens, technical DTOs,
transverse types. **No implementation.** Depends on `@mentora/kernel` and
`@mentora/shared` (ADR 0003, family 4, technical sub-kind).

> This is the *technical* contracts package. A bounded context's *domain*
> contracts (its published Events and Commands, F2.5) live in a separate
> `@mentora/contracts-<context>` package, created in later lots.

## What's inside

| Area | Exports |
|------|---------|
| **tokens** | `Token<T>`, `createToken`; the platform tokens `CLOCK`, `ID_GENERATOR`, `LOGGER`, `CONFIG` |
| **dto** | `Page<T>`, `PageRequest`, `Sort`, `SortDirection` |
| **types** | `CorrelationId`, `Timestamped`, `Identifiable<TId>` |

## Why tokens live here, ports live in kernel/shared

The **port interfaces** (`Clock`, `IdGenerator`, `Logger`, `Config`) belong to the
rings that define them (kernel, shared). The **DI tokens** that name those ports
for a container belong here, so the inner rings never depend on a DI framework
(F4.4 I-7). An app's composition root binds `CLOCK` → a concrete clock adapter;
everything else asks for the token, not the implementation.
