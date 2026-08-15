import type { SequenceViolation } from '../result/sequence-outcome.js';

/**
 * The Exception channel of the Sequence (A-7): a malformed call — pas 1:
 * "malformé → Exception, fin". Business refusals are NEVER thrown (they are
 * Decision values); technical failures are SequenceFailure values.
 */

export abstract class SequenceExecutionException extends Error {
  abstract readonly code: string;

  constructor(message: string) {
    super(message);
    this.name = new.target.name;
    Object.setPrototypeOf(this, new.target.prototype);
  }
}

/** Pas 1: the payload does not form a Command of the dictionary — end. */
export class SequenceReceptionException extends SequenceExecutionException {
  readonly code: string = 'SEQUENCE.RECEPTION';

  constructor(readonly violations: readonly SequenceViolation[]) {
    super(
      `Payload is not a valid command: ${violations
        .map((violation) => `${violation.field} (${violation.code})`)
        .join(', ')}`,
    );
  }
}
