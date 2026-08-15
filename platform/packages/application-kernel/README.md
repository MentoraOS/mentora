# @mentora/application-kernel

THE official pipeline of the platform — the **Séquence de Commande** (F4.1 §2)
as a generic, domain-agnostic harness. "Le pipeline n'appartient pas au
domaine. Le domaine est injecté dans le pipeline. Le pipeline reste générique."
Every `application-*` package (Agreement today; Offer, Settlement, Membership
tomorrow) instantiates it by injecting a `SequenceDefinition`; the kernel
depends on **no domain**.

## The ten frozen steps (A-2 — "dix pas, cet ordre, aucun autre")

`Reception → IdentityInjection → TimeInjection → Loading → SourceValidities →
Act → RefusalReturn → AtomicRetention → Publication → ResponseAndJournal`

Order corrected by F4.1.99: Loading PRECEDES the validities. There is **no**
Authorization step (dispatch, R-C/A-8) and **no** Projection step (parallel
readers of published facts, F4.99) — R2 wins.

## The six frozen steps of the Lecture (F4.99 §1 — added Lot 1C-4, additive)

`Reception → IdentityInjection → RightsCheck (R-C) → Reading → Response →
Journal` — "réception → identité → R-C → lecture → réponse → journal".
Closure law: THREE Sequences (Commande 10, Réaction 6, Lecture 6), no fourth
path. The Lecture never mutates, never retains, never publishes, never
retries (a technical throw is a Failure VALUE; transport retries are M-8's).
No TimeInjection: the frozen six hold no time step. `read/` carries the
generic `ReadDefinition`/`ReadExecutor` and the `QueryDispatch` (F4.1 §6:
table fermée, ONE reader per Query, fail closed at assembly).

## The six frozen steps of the Réaction (F4.99 §1 — added Lot 1C-5, additive)

`FactReception (Inbox — dedup by FACT IDENTITY, M-4) → Injections
(propagated correlation, ONE instant — A-6) → Reaction (PURE function:
position/mapping → commands) → AtomicRetention (Inbox mark + position +
emitted commands, ONE write — the Outbox de commandes, F4.99 §2) → Relay
(structural: the command-outbox relay dispatches at-least-once) → Journal.`

The third and last execution path — "il n'existe aucun quatrième chemin".
NO Refusal channel exists here: a Process Manager never decides (P-3);
a journey dead-end is a POSITION (Abandoned + Signal, P-8), never a
pipeline outcome. Duplicates are absorbed (at-least-once, loi 15);
technical Failures retry from pas 3 within a bounded budget (M-8), then
ABANDON with a journaled witness. `reaction/` carries the generic
`ReactionDefinition`/`ReactionExecutor`/`ReactionBuilder` and the
`ReactionDispatch` (M-5: routing = a projection of declared subscriptions,
closed table, no dynamic discovery, no runtime reflection).

## Shape

- `step/` — the frozen `SEQUENCE_STEPS` constant + the ten stage classes.
- `interfaces/` — `SequenceDefinition`, the plug a context injects.
- `executor/` — `SequenceExecutor`: the one runner of the ten steps; refusal
  exits at pas 7; retryable Failures re-enter at Loading (pas 4) with ONE
  instant per execution (A-6); exhausted budget → journaled abandon.
- `builder/` — `SequenceBuilder`: composition composes, handlers never build.
- `journal/` — `SequenceJournalPort` (A-10; Journal ≠ Log, F5.3): step
  journal, error journal, abandon journal.
- `result/` — `SequenceOutcome` + the A-7 channels as VALUES (Refusal,
  Failure); `errors/` — the Exception channel (malformed calls only).
- `context/` — the read view of one execution; `testing/` —
  `RecordingJournal` for specs.
