/**
 * @mentora/adapters-persistence-identity — the PostgreSQL/Prisma persistence
 * adapter of the Identity & Access registries (Stories #64/#68/#72/#75/#77).
 * The ports are the domain's; everything here is mechanism (S-1). The
 * Session registry is STATE ONLY — no fact table, no outbox, structurally.
 * The testing/ harness is exported for the integration gates; real data
 * never enter it (S-9).
 */

export * from './client/identity-prisma-client.js';
export * from './errors/identity-persistence-errors.js';
export * from './serialization/identity-snapshot-serializer.js';
export * from './snapshot/credential-snapshot-mapper.js';
export * from './snapshot/session-snapshot-mapper.js';
export * from './fact-stream/credential-fact-mapper.js';
export * from './fact-stream/credential-fact-stream-store.js';
export * from './outbox/credential-outbox-store.js';
export * from './concurrency/identity-optimistic-concurrency-guard.js';
export * from './retention/credential-retention-engine.js';
export * from './retention/session-retention-engine.js';
export * from './repository/prisma-credential-repository-adapter.js';
export * from './repository/prisma-session-repository-adapter.js';
export * from './read-model/prisma-identity-state-read-adapter.js';
export * from './relay/prisma-identity-relay-source.js';
export * from './module/identity-persistence-module.js';
export * from './testing/identity-persistence-fixture.js';
export * from './testing/identity-persistence-mother.js';
export * from './testing/uuid-source.js';
