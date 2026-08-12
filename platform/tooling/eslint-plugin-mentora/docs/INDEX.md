# Rule index

- [MENTORA0001](rules/MENTORA0001.md) — `mentora/forbidden-vocabulary`: Forbids the banned words of the official Glossary (Booking, User, Wallet, Rating…) in declaration names.
- [MENTORA0002](rules/MENTORA0002.md) — `mentora/no-forbidden-suffixes`: Forbids the transverse banned name parts: -Manager, -Helper, -Util(s), -Impl, -Data, -Info, -Common, -Shared suffixes, Base-/Abstract- prefixes, and the bare generic -Service.
- [MENTORA0003](rules/MENTORA0003.md) — `mentora/event-naming`: In event files (events/ directories, *.event.ts), every exported PascalCase declaration must be <Truth><PastParticiple> (…ed, or a ratified irregular: Struck, Withdrawn, Kept, Undeliverable).
- [MENTORA0004](rules/MENTORA0004.md) — `mentora/command-naming`: In command files (commands/ directories, *.command.ts), every exported declaration must be <Verb><Truth> (at least two words) and never start with the banned generics Set/Save.
- [MENTORA0005](rules/MENTORA0005.md) — `mentora/query-naming`: Declarations ending in Query must carry a named truth/aspect (≥ 1 word before the suffix) — the ratified catalogue includes single-stem reads (MembershipQuery).
- [MENTORA0006](rules/MENTORA0006.md) — `mentora/policy-naming`: Declarations ending in Policy must carry a named rule (≥ 1 word before the suffix) — the ratified catalogue includes single-stem policies (ReschedulePolicy, ConfirmationPolicy, F3.3 §6).
- [MENTORA0007](rules/MENTORA0007.md) — `mentora/specification-naming`: Declarations ending in Specification must carry a named question (≥ 1 word before the suffix).
- [MENTORA0008](rules/MENTORA0008.md) — `mentora/repository-naming`: Declarations ending in Repository must be <Truth>Repository (≥ 1 word before the suffix).
- [MENTORA0009](rules/MENTORA0009.md) — `mentora/projection-naming`: Declarations ending in Projection must be <Name>Projection and those ending in ReadModel must be <Name>ReadModel (≥ 1 word before the suffix).
- [MENTORA0010](rules/MENTORA0010.md) — `mentora/process-manager-naming`: Declarations ending in Process must be <Journey>Process (≥ 1 word before the suffix).
- [MENTORA0011](rules/MENTORA0011.md) — `mentora/adapter-naming`: Declarations ending in Adapter must be <Provider><Capability>Adapter (≥ 2 words before the suffix).
- [MENTORA0012](rules/MENTORA0012.md) — `mentora/port-naming`: Declarations ending in Port must be <Capability>Port (≥ 1 word before the suffix).
- [MENTORA0013](rules/MENTORA0013.md) — `mentora/application-service-naming`: Declarations ending in ApplicationService must be <UseCase>ApplicationService (≥ 1 word before the suffix).
- [MENTORA0014](rules/MENTORA0014.md) — `mentora/exception-naming`: Declarations ending in Exception must be <Truth><Reason>Exception (≥ 2 words before the suffix).
- [MENTORA0015](rules/MENTORA0015.md) — `mentora/no-dto-in-domain`: Forbids Dto/DTO in declaration names inside domain packages; at the edges the ratified word is <X>Payload.
- [MENTORA0016](rules/MENTORA0016.md) — `mentora/no-framework-import-in-domain`: Forbids framework/vendor imports (NestJS, Prisma, TypeORM, Express…) inside domain packages.
