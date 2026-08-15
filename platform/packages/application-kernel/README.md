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
