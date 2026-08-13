# @mentora/contracts-agreement

**The published language of the Agreement domain** (Engagement bounded context)
— the model for every future contracts package. All other packages speak to
Agreement exclusively through these contracts. **Types + contract validation
only** — no business logic, no implementation, no framework. Independently
publishable.

## The separation this package demonstrates

| Transversal (lives in `@mentora/contracts` — REUSED, never redeclared) | Agreement-specific (lives here) |
|---|---|
| `CommandEnvelope/EventEnvelope/QueryEnvelope`, `EnvelopeMetadata` (M-3) | the 8 fact contracts, the 8 command contracts |
| `CorrelationId`, `CausationId` (envelope-only, M-3) | `AgreementStateQuery` + `AgreementStateResponse` (the only ratified read, F3.3 §5) |
| `CommandId` (act identity, F4.1 §3) | `AgreementId`/`OfferId`/`ClientId`/`ExpertId` types + validators |
| `Page<T>`, `Sort` (unused today — no ratified collection read) | refusal reasons union, contract violations, schemas, serializers, generations |

**Mutualized this lot** (transversal by law — M-3 governs every domain):
`CausationId`, the three envelopes, and `CommandId` were added to
`@mentora/contracts`; this package only *instantiates* them
(`AgreementEventEnvelope = EventEnvelope<AgreementEventContract>`).

## Constitutional posture

- **The fact ignores its transport, forever** (M-3): correlation/causation/
  attempts ride the **envelope**; the published facts carry their instant
  (`occurredAtMs`), their identity (`agreementId`+`sequence`) and their
  generation (`contractVersion`) — never transport metadata.
- **No instant on wire commands** (A-6, signaled): the Application layer
  injects the one instant per execution; client-supplied time would be ambient
  time. Cross-domain preconditions arrive **as data** (loi 15).
- **V-laws executable** (F4.3): additive evolution (validators are **tolerant
  readers** — unknown fields pass), rename/removal = new contract, the
  generation manifest (`AGREEMENT_CONTRACT_GENERATIONS`) is V-1's ownership
  written down, `compatibleWith` implements V-4 reading.
- **Errors are data**: `AgreementRefusalContract` (the published Decision
  refusal) and `AgreementContractViolation` (coded structure defects) — never a
  JavaScript `Error` across a boundary.
- **Determinism**: serializers sort keys recursively — the same contract always
  yields byte-identical JSON.

## Layout

```
src/
├── ids/           public id types + contract validators (CommandId reused from core)
├── errors/        refusal reasons (single definition — the domain imports it) + violations
├── events/        the 8 published facts (wire shapes)
├── commands/      the 8 published commands (wire shapes)
├── queries/       AgreementStateQuery (the only ratified read)
├── responses/     AgreementStateResponse
├── messages/      Agreement-typed instantiations of the CORE envelopes
├── schemas/       data-driven schema engine + one schema per contract
├── validators/    structure + generation validation (tolerant readers)
├── serializers/   deterministic JSON, versioned, coded failures
├── version/       the generation manifest (V-1..V-5)
└── index.ts       the single public entrypoint
```

Omitted by design (signaled): `ports/` — ports belong to their consumers
(F4.4 I-4); the registry port lives in the domain; queries are consumed through
the Query Dispatch (F4.1 §6). `metadata/` — envelope metadata is transversal
and lives in the core.

## Relationship to `@mentora/domain-agreement`

The domain **imports** its id types and the refusal-reason union from here
(single definition, no duplication). The domain's in-memory events carry
`Instant`/VO types; these wire contracts carry primitives — the mapping is the
Application layer's job (a wire command has no instant to inject *from*; the
domain command receives the injected one).
