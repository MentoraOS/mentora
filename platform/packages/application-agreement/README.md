# @mentora/application-agreement

The **application layer** of the Agreement domain: the Séquence de Commande
(F4.1) orchestration harness. *Le domaine décide. L'application orchestre. Les
adapters exécutent.* No business rule, no framework, no I/O — orchestration
only (F4.1 §1: the Application Service owns the Sequence, the transaction, the
ports it commands, its correlated journal — never a rule, an invariant, a fact,
a truth, or state between two calls).

> **Status — Lot 1C-3 (Command side complete).** 1C-1 shipped the frozen
> skeleton; 1C-2 moved the generic pipeline into `@mentora/application-kernel`
> (this package re-exports and instantiates it); 1C-3 ships the **eight
> Application Services** and their **SequenceDefinitions**. **No query side,
> no process manager, no projection yet** — later sub-lots, each on explicit
> CTO order.

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
├── definitions/  1C-3 — the eight SequenceDefinitions: what Agreement INJECTS
│                 into the Golden Pipeline (receive/load/map/act/retain); the
│                 pipeline stays generic, the domain is plugged in
├── services/     1C-3 — the eight `<UseCase>ApplicationService` (F4.1 §8,
│                 F2.5 §9): guardians of execution, one Command each (A-1),
│                 boring by law (F4.1 §7) — instantiate their definition, hand
│                 it to the ratified SequenceBuilder, delegate to the ONE
│                 SequenceExecutor; zero business logic, zero pipeline code
└── composition/  EMPTY until 1C-7 — the Root is built last (I-2/I-3, unique
                  per executable, F4.4.99)
```

## The eight carriers (A-1: one Command, one Application Service)

| Command (frozen) | Service | Act |
|---|---|---|
| `RequestAgreement` | `RequestAgreementApplicationService` | birth via `AgreementFactory` (frame as data, loi 15) |
| `AcceptAgreement` | `AcceptAgreementApplicationService` | Requested → Accepted |
| `RejectAgreement` | `RejectAgreementApplicationService` | Requested → Rejected (terminal) |
| `ConfirmAgreement` | `ConfirmAgreementApplicationService` | Accepted → Confirmed (settlement as data) |
| `RescheduleAgreement` | `RescheduleAgreementApplicationService` | Confirmed ⇄ Confirmed (injected `ReschedulePolicy`) |
| `CancelAgreement` | `CancelAgreementApplicationService` | Confirmed → Cancelled (injected `AgreementCancellationPolicy`) |
| `LapseAgreementRequest` | `LapseAgreementRequestApplicationService` | Requested\|Accepted → Lapsed (time tooling) |
| `ElapseAgreement` | `ElapseAgreementApplicationService` | Confirmed → Elapsed (time tooling) |

The frozen authority for the eight names is **F3.2-A** (`source/domain/02`,
Agreement design) + the F3.3 catalogues; the dictionary's §5 lists the first
six, and the state-machine law ("aucune transition sans commande") requires
the two time-tooling commands. The mandate's word "Handler" has no R2 basis on
the command side: F4.1 §8 freezes `<UseCase>ApplicationService`, and "handler"
in F4.99 designates only the FACT consumer of the Séquence de Réaction.

## The mandated improvement — STOPPED (règle constitutionnelle : R2 gagne)

The 1C-3 mandate ordered, in addition, a `PipelineDefinition` (retry / journal
/ publication / retention / failure "policies") and a `PipelineObserver`
(beforeStep/afterStep/onRefusal/onFailure/onRetry/onFinish hooks) supported by
the Golden Pipeline. **Both contradict R2 — built neither** (the mandate's own
clause: "Si cette amélioration entre en contradiction avec R2, STOP"):

1. **"Policy" is a frozen building block** (F3.1): "publiée d'avance, avec
   paramètres **du produit** … rend une Décision motivée". Retry budgets and
   journal wiring are **technical** configuration (F4.4 I-5: "pools, timeouts,
   tailles de files"; the criterion is "le permis contre la performance") — a
   technical `RetryPolicy`/`JournalPolicy` object would misuse the reserved
   block name.
2. **Journal, publication, retention are LAWS, not axes**: A-10 mandates one
   record per step (no journal policy can exist); A-4 gives publication to the
   Outbox relay ("publication hors relais" is an absolute interdiction — there
   is nothing to configure on the pipeline); A-3 makes retention one atomic
   act that "ne parle à personne". A configuration object over these would be
   the forbidden "flag caché qui gouverne du métier" (F4.4 §5).
3. **Observers/hooks between steps are a destroyed architecture**: A-2 — "La
   Séquence est fermée : dix pas, cet ordre, aucun autre"; F4.1 §11 destroys
   the "**Mediator à pipeline de behaviors**" ("toutes détruites"); the
   anti-pattern "**le behavior-cerveau**" names it; F4.99 §9 re-destroys
   "Plugin". R2 defines **no** observer/hook/interceptor mechanism anywhere
   (sole "crochets" = I-11's four Runtime resource-lifecycle phases).
4. **What R2 already provides instead**: the retry budget is `maxAttempts`
   (technical, injected — I-5, bounded by M-8); the per-step observation IS
   the Journal (A-10) behind `SequenceJournalPort` — an adapter below the port
   may fan out derived notifications without touching the pipeline (I-12);
   business metrics come free from the Reasons (F4.1 §9).

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
| 2 | 1C-3 handlers: **ExpireAgreement**, **CompleteAgreement** | the frozen commands are `LapseAgreementRequest` and `ElapseAgreement` (F3.2-A, `source/domain/02` — the dictionary's §5 lists the six person-issued commands; the state-machine law of F3.3 requires the two time-tooling ones); *Expired* is **reserved to Consent** (VD-0044); "Complete" does not exist — `Elapsed` is the frozen end of a confirmed agreement | **DONE in 1C-3**: the 8 ratified Application Services shipped, nothing else (citation corrected from "F2.5 §5" to F3.2-A/F3.3 this lot) |
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
