# @mentora/runtime-logging

Implementations of the SHARED `Logger` contract (owned by shared, 0B). F5.3:
the **Log** is the technical emission — "perdable et borné", "**aucune
matière, aucun secret**" (O-2/P7), timestamp of the emitting layer,
correlation carried when it exists — forever distinct from the applicative
**Journal** (probant; this package never writes one). `StructuredLogger`
(clock INJECTED — A-6), deterministic `jsonLogFormatter` (sorted keys),
sinks (console — the one lawful console write —, memory), `LogRotationStrategy`
(abstract; file handling is an adapter resource, I-11). Levels are an
engineering convention of the shared contract — the canon defines severity
only for Alerts.
