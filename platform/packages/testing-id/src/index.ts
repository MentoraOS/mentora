/**
 * @mentora/testing-id — deterministic identifiers for tests.
 *
 * Implementations of the kernel `IdGenerator` port that produce predictable
 * ids: sequential (`id-1`, `id-2`…), seeded UUIDs (same seed → same sequence),
 * or a constant. Determinism makes assertions exact and failures reproducible.
 */

export { SequentialIdGenerator } from './sequential-id-generator.js';
export { SeededUuidGenerator } from './seeded-uuid-generator.js';
export { ConstantIdGenerator } from './constant-id-generator.js';
