import { SequenceExecutionException } from '@mentora/application-kernel';

/**
 * PERSIST.CORRUPTION (RC-2 §8) — a stored row that lies (checksum mismatch,
 * malformed payload): an EXCEPTION + Signal, never a lying `none` (Blueprint
 * §3.1). Extends the one canonical base so it propagates RAW through the
 * LoadingStage (A-7: a defect is never converted into a retryable Failure).
 */
export class AgreementPersistenceCorruptionException extends SequenceExecutionException {
  readonly code: string = 'PERSIST.CORRUPTION';

  constructor(readonly agreementId: string, detail: string) {
    super(`Agreement registry row corrupted for '${agreementId}': ${detail}`);
  }
}

/**
 * PERSIST.VERSION_CONFLICT (RC-2 §8; F5.2 §4 verbatim: "un conflit optimiste
 * (deux Séquences, une version) est une Failure TRANSITOIRE, jamais une
 * Decision"). A plain Error ON PURPOSE: the AtomicRetentionStage catches the
 * throw and yields the retryable Failure channel — the pipeline re-enters at
 * pas 4 within its technical budget (S-3).
 */
export class AgreementVersionConflictError extends Error {
  readonly code = 'PERSIST.VERSION_CONFLICT';

  constructor(agreementId: string, expectedVersion: number) {
    super(
      `PERSIST.VERSION_CONFLICT: two Sequences, one version — agreement '${agreementId}' expected v${String(expectedVersion)}`,
    );
  }
}
