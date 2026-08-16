# composition/

**Filled at Lot 1C-7** — the assembly of the Agreement context. The Root is
"le seul endroit du système où des types concrets existent" (F4.4 §2): it
builds the Policies (with their injected PRODUCT parameters), the nine
Application Services, the Dispatchers **and their tables** — and never a
truth (I-3: the Aggregates are born by Factories, reconstituted by their
registry).

`composeAgreement(providers)` builds the WHOLE graph explicitly — Pure DI:
no service locator, no hidden singleton, no dynamic resolve, no container.
"La règle du regard" (I-2): above the Root, everything receives, nothing
searches.

The Root proper is **unique per executable** (F4.4.99). No executable exists
yet — the future app's Root calls `composeAgreement` with its real adapters
(repository, read/rights ports, clock, journals) and its validated
configuration, and receives the boot-validated graph (F4.4 §7, fail closed:
every ratified Command has its one carrier, the query table serves exactly
the one ratified read, "une seule erreur = pas de démarrage").

The reaction table is assembled **closed and empty**: no Agreement reaction
is ratified today (1C-5 STOP on `NoShowSettlementProcess`, 1C-6 STOP on the
projections) — declaring a subscription here would complete the Corpus.
