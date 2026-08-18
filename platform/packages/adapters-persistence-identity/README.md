# @mentora/adapters-persistence-identity

The PostgreSQL/Prisma registries of Identity & Access — the FIRST real
implementations of the domain's frozen `CredentialRepository` and
`SessionRepository` ports (Stories #64/#68), strictly per the frozen
Agreement precedent and the Canonical Persistence Model (RC-1). The ports
are the law; everything here is mechanism (S-1). The only vendor import is
the package-local generated Prisma client (A-9/I-7 — the types of the
outside die here).

## Two registries, one deliberate asymmetry

- **Credential** — the full atomic act (pas 8, Blueprint order): (1) version
  control → (2) fact-stream append → (3) private photograph upsert → (4)
  Outbox de faits → (5) commit, in ONE Serializable transaction that talks
  to NO ONE (A-3). Classified AFTER rollback: the declared **R-A key**
  (partial unique index `credential_active_principal_ra_key`) → Refusal
  **`CredentialAlreadyExists`** (the settled dictionary name,
  `<Truth>AlreadyExists` family — F3.2-B precedent); snapshot-pkey collision
  or stale version → `IdentityVersionConflictError` thrown (transient
  Failure, S-3); engine errors rethrown (R-10). Corruption on load →
  `PERSIST.CORRUPTION`, raw.
- **Session** — STATE ONLY, structurally: the engine has no fact step and
  the schema has **no Session fact/outbox/inbox table at all** ("aucun fait
  publié" — what has no table cannot leak). The integration gate proves the
  absence against `information_schema`.

## RFC-001 (ratified) — RetentionContext

`retain(unit, context?)`: the OPTIONAL envelope values (`correlationId`,
`causationId`, `traceparent`) ride to the **Credential outbox columns** in
the same atomic act — "corrélation portée quand elle existe" (F5.3 §2). An
absent context writes NULL: the pre-RFC behavior, additively preserved.

## The acceptance criterion (Story #75)

The two domain contract suites — written ONCE (I-10) — are REPLAYED here
against the real engine (`src/integration.spec.ts`), plus the relay contract
suite against `PrismaIdentityRelaySource` (Task #77). Gated on the declared
`MENTORA_IDENTITY_DATABASE_URL`: absent → skip; the official gate runs real.

## Generated client

`prisma generate` emits package-local ESM TypeScript into `src/generated/`
(the `prisma-client` generator) — never committed, rebuilt by `build`/
`typecheck`; the Agreement package's default-output generation is never
touched (two schemas, zero collision).
