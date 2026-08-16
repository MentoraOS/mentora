# @mentora/runtime-health

The runtime's health verdicts. R-6, verbatim: "Readiness = aptitude aux
trois Séquences ; Liveness = existence du processus ; ni l'une ni l'autre ne
jugent le métier" (a refusal rate is never a death signal). F4.4 §6:
readiness only after complete validation AND rehydrated relays/Échéancier.
`HealthCheck` (startup/readiness/liveness), `CompositeHealthCheck`,
`HealthRegistry` (closed declared list), `HealthReport` — all verdicts FAIL
CLOSED; a throwing check is a described Failure (R-10), never a silent pass.
