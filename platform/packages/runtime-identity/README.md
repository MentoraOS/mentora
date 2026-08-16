# @mentora/runtime-identity

Implementations of the kernel `IdGenerator` port. `UuidFactory` (canonical
UUIDs from the platform CSPRNG), `RandomIdFactory` (prefixed technical ids),
`createIdentityProvider`. No `SequentialIdFactory`: deterministic generators
are test doubles and live in `@mentora/testing-id` (0C); a production
sequential id collides across instances by construction (R-2: instances
share nothing).
