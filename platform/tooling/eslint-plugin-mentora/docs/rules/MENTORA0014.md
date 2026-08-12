# MENTORA0014 — `mentora/exception-naming`

> Declarations ending in Exception must be <Truth><Reason>Exception (≥ 2 words before the suffix).

## Justification

An Exception refuses a malformed call about a named truth for a named reason.

## R2 reference (the law this rule executes)

R2 source/domain/01-tactical-building-blocks.md (Domain Errors, Naming `<Truth><Reason>Exception`) · F2.5.2 (DepositRetentionActiveException)

## Valid

```ts
DepositRetentionActiveException
AgreementConditionsMissingException
```

## Invalid

```ts
AgreementException
Exception
```

*Permanent diagnostic code: `MENTORA0014`. Codes are never renumbered, never reused.*
