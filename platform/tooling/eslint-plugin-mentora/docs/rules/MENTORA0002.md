# MENTORA0002 — `mentora/no-forbidden-suffixes`

> Forbids the transverse banned name parts: -Manager, -Helper, -Util(s), -Impl, -Data, -Info, -Common, -Shared suffixes, Base-/Abstract- prefixes, and the bare generic -Service.

## Justification

A Manager/Helper/Util is knowledge without a home; a bare <Truth>Service is a catch-all. A qualified capability service (<Truth><Capability>Service) remains legal (F2.5.2).

## R2 reference (the law this rule executes)

R2 source/constitution/04-bilingual-dictionary.md §9 (interdits transverses) + F2.5.2 clarification · source/domain/01-tactical-building-blocks.md (Naming Constitution)

## Valid

```ts
class AgreementSchedulingService {}
class AgreementFactory {}
class OfferRepository {}
```

## Invalid

```ts
class AgreementManager {}
class DateHelper {}
class StringUtils {}
class AgreementServiceImpl {}
class AgreementService {}
class BaseAggregate {}
```

*Permanent diagnostic code: `MENTORA0002`. Codes are never renumbered, never reused.*
