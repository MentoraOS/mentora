import { SequenceExecutionException } from '@mentora/application-kernel';

/**
 * PERSIST.CORRUPTION (RC-2 §8) — a stored row that lies (checksum mismatch,
 * malformed payload): an EXCEPTION + Signal, never a lying `none`. Extends
 * the one canonical base so it propagates RAW through the LoadingStage
 * (A-7: a defect is never converted into a retryable Failure).
 */
export class IdentityPersistenceCorruptionException extends SequenceExecutionException {
  readonly code: string = 'PERSIST.CORRUPTION';

  constructor(readonly unitId: string, detail: string) {
    super(`Identity registry row corrupted for '${unitId}': ${detail}`);
  }
}

/**
 * PERSIST.VERSION_CONFLICT (RC-2 §8; F5.2 §4 verbatim: "un conflit optimiste
 * (deux Séquences, une version) est une Failure TRANSITOIRE, jamais une
 * Decision"). A plain Error ON PURPOSE: the AtomicRetentionStage catches the
 * throw and yields the retryable Failure channel — the pipeline re-enters at
 * pas 4 within its technical budget (S-3). One class serves both registries;
 * the unit identity names the subject.
 */
export class IdentityVersionConflictError extends Error {
  readonly code = 'PERSIST.VERSION_CONFLICT';

  constructor(unitId: string, expectedVersion: number) {
    super(
      `PERSIST.VERSION_CONFLICT: two Sequences, one version — unit '${unitId}' expected v${String(expectedVersion)}`,
    );
  }
}
