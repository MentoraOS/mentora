import { SequenceExecutionException } from '../errors/sequence-errors.js';
import type { SequenceViolation } from '../result/sequence-outcome.js';

/**
 * The Exception channel of the Réaction (A-7: a caller/producer defect —
 * never a business refusal, never a technical Failure). The executor itself
 * returns exception OUTCOMES as values (pas 1); this class exists for
 * adapters that must THROW at their boundary. It extends the one canonical
 * base so raw propagation stays uniform across the three Sequences.
 */
export class ReactionReceptionException extends SequenceExecutionException {
  readonly code: string = 'REACTION.RECEPTION';

  constructor(readonly violations: readonly SequenceViolation[]) {
    super(
      `Payload is not a valid published fact: ${violations
        .map((violation) => `${violation.field} (${violation.code})`)
        .join(', ')}`,
    );
  }
}
