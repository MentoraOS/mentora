# @mentora/adapters-persistence-agreement

The PostgreSQL/Prisma registry of the Agreement — the FIRST real
implementation of the domain's frozen `AgreementRepository` port, strictly
per the Blueprint (docs/engineering/06) and the Canonical Persistence Model
(RC-1). The port is the law; everything here is mechanism (S-1). The only
vendor import is `@prisma/client` (A-9/I-7 — the types of the outside die
here).

## The atomic act (pas 8 — Blueprint order, exactly)

`retain(unit)` = ONE Serializable transaction that talks to NO ONE (A-3):
(1) version control → (2) fact-stream append → (3) private photograph
upsert → (4) Outbox de faits rows → (5) commit. Collisions leave through
their lawful doors, classified AFTER rollback: R-A exclusion → Refusal
`TimeSlotUnavailable`; identity collision → Refusal `TransitionUnavailable`
(R-B); stale version → `AgreementVersionConflictError` thrown (transient
Failure, S-3 — the pipeline re-enters at pas 4); engine errors rethrown
(R-10). Corruption on load → `PERSIST.CORRUPTION` Exception, raw — never a
lying unit.

## Reconstruction

"Snapshot privé + delta" (F5.2 §12): the photograph is written at EVERY
retention (delta = 0 by construction); `byId` = row → checksum →
VersionedPayload v1 → `Agreement.fromSnapshot`. No event-sourcing engine —
the fact stream is the eternal provenance (O-4), Réadmission source (S-6)
and the relay's feed, never a state rebuilder.

## Schema (prisma/) — RC-1 verdicts applied

`AgreementSnapshot` (photo + version + checksum + the MATERIALIZED index of
the declared R-A key and catalogue walk) · `AgreementFact` (append-only,
unique(agreementId, sequence)) · `AgreementOutbox` (envelope fields + wire
fact; correlation/causation NULL at write — the frozen port cannot carry
them, "corrélation portée quand elle existe", SIGNALED) · `AgreementInbox`
(per-consumer register, unused until a consumer exists). NOT created:
`AgreementMigration` (the Migration Record IS `_prisma_migrations`, the
mechanism's own bookkeeping — a duplicate is forbidden) and
`AgreementSchemaGeneration` (generations are a DERIVED registry verified at
boot from the code manifests — S-4/M-5). The R-A key is a PostgreSQL
EXCLUDE constraint (btree_gist) in the hand-authored migration — executed
by the Migration species, never by an Application boot (S-7).

## Tests

Unit (no database): mappers (byte-identical round-trips), all EIGHT wire
facts validator-clean (V-1), checksum/corruption, guard classification.
Integration (real PostgreSQL, gated on `MENTORA_AGREEMENT_DATABASE_URL`
read through runtime-config's environmentSource — absent ⇒ suite skips,
the gate stays green): the `AgreementPersistenceContractSuite` (the port's
promises, same behavior as the in-memory double — I-10), atomic
rollback-totality, SQL constraints, corruption, read ports, the I-11
lifecycle module. Dev database: `docker run` a disposable postgres:16 and
`prisma migrate deploy` (see the Blueprint §7; spec data only — S-9).
