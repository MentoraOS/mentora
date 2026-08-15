# @mentora/application-agreement

The **application layer** of the Agreement domain: the Séquence de Commande
(F4.1) orchestration harness. *Le domaine décide. L'application orchestre. Les
adapters exécutent.* No business rule, no framework, no I/O — orchestration
only (F4.1 §1: the Application Service owns the Sequence, the transaction, the
ports it commands, its correlated journal — never a rule, an invariant, a fact,
a truth, or state between two calls).

> **Status — Lot 1C-1 (Architecture).** This lot ships the package's frozen
> skeleton: the ten steps, the ports, the three error channels, reception, and
> the wire→domain seam. **No handler, no query side, no process manager yet** —
> they arrive in the later sub-lots, each on explicit CTO order.

## The architecture (what each folder is)

```
src/
├── pipeline/     the TEN frozen steps (A-2, F4.1.99 order) — the stages of
│                 1C-2 implement these and no others
├── ports/        ports owned by the application (I-4): SequenceJournalPort
│                 (A-10 — one record per step, correlated, no content)
├── errors/       the three channels of A-7: Exception (malformed call) and
│                 Failure (technical, retryable, a VALUE); the Refusal is the
│                 domain's Decision, transported untouched
├── validators/   pas 1 — Reception: delegates to the published language
│                 (@mentora/contracts-agreement), adds nothing
├── factories/    the wire → domain seam: published command + INJECTED instant
│                 → domain command (ids pass through, slots go through the VO
│                 door, parties get branded)
└── composition/  EMPTY until 1C-7 — the Root is built last (I-2/I-3, unique
                  per executable, F4.4.99)
```

## The ten steps (the pipeline's law — F4.1 §2, order corrected by F4.1.99)

Reception → IdentityInjection · TimeInjection (injection block, A-6) →
**Loading** → **SourceValidities** (loading FIRST — F4.1.99) → Act →
RefusalReturn → AtomicRetention (talks to no one, A-3) → Publication (owned by
the **Outbox relay**, A-4 — the service never publishes inline) →
ResponseAndJournal (A-10).

## Signals to the CTO (règle constitutionnelle : R2 gagne)

| # | Mandate says | R2 says | Resolution |
|---|--------------|---------|------------|
| 1 | 1C-2 stages: Validation → **Authorization** → Loading → … → **ProjectionStage** | A-2: ten steps, **this order, no other**; F4.1.99: **Loading precedes the validities**; projections are parallel readers of published facts (F4.99), never a step; authorization = dispatch (R-C, A-8) + the owners' NON (T-9) | the pipeline implements the **ten frozen steps**; no Projection/Authorization stage exists |
| 2 | 1C-3 handlers: **ExpireAgreement**, **CompleteAgreement** | the frozen commands are `LapseAgreementRequest` and `ElapseAgreement` (F2.5 §5); *Expired* is **reserved to Consent** (VD-0044); "Complete" does not exist — `Elapsed` is the frozen end of a confirmed agreement | 1C-3 will ship the **8 ratified handlers**, nothing else |
| 3 | 1C-5: Process Managers "uniquement ceux présents dans R2" | F4.2 names two canonical journeys: `ErasureProcess` (effacement — owned by the Compte journey, not Agreement) and **`NoShowSettlementProcess`** ("l'accord échu dont la rencontre ne s'ouvre jamais") — the Agreement-adjacent ratified PM | 1C-5 scope = `NoShowSettlementProcess` (to be confirmed at that lot; its full definition spans Consultation/Economy facts) |
| 4 | 1C-6: `AgreementStateProjection`, `AgreementTimelineProjection` | **neither exists in R2**; the ratified Agreement-adjacent projections are `AgreementHonoredProjection`, `NoShowProjection`, `CalendarProjection`, `FreeSlotsProjection` (F2.5 §6) | 1C-6 will STOP and signal, as the mandate itself instructs |

## Dependency graph

```
application-agreement ─► domain-agreement ─► contracts-agreement ─► contracts ─► kernel
                     └──► contracts-agreement (wire types)
                     └──► contracts (CorrelationId)
                     └──► kernel (Result, Instant)
```

Arrow inward only (I-1); no framework import anywhere; adapters unknown here
(they implement these ports below, I-12).
