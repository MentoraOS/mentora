/**
 * @mentora/adapters-persistence-agreement — the PostgreSQL/Prisma registry
 * of the Agreement (Blueprint 2A-2; RC-1 canonical model). The port stays
 * the domain's untouched facade; everything here is mechanism (S-1). The
 * ONLY vendor import of the package is @prisma/client (A-9/I-7 — the types
 * of the outside die here).
 */

export * from './errors/agreement-persistence-errors.js';
export * from './serialization/agreement-snapshot-serializer.js';
export * from './snapshot/agreement-snapshot-mapper.js';
export * from './fact-stream/agreement-fact-mapper.js';
export * from './fact-stream/agreement-fact-stream-store.js';
export * from './concurrency/agreement-optimistic-concurrency-guard.js';
export * from './outbox/agreement-outbox-store.js';
export * from './retention/agreement-retention-engine.js';
export * from './repository/prisma-agreement-repository-adapter.js';
export * from './read-model/prisma-agreement-state-read-adapter.js';
export * from './module/agreement-persistence-module.js';
export * from './testing/agreement-persistence-mother.js';
export * from './testing/agreement-persistence-fixture.js';
export * from './testing/agreement-persistence-contract-suite.js';
