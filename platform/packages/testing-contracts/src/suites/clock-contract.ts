import type { Clock } from '@mentora/kernel';
import { InvariantViolationError } from '@mentora/kernel';

import type { ContractSuite } from '../contract.js';

/**
 * The promises every `Clock` implementation must keep. Runs against the fake
 * (testing-clock) and, later, the system-clock adapter — same suite, same
 * proof.
 */
export const clockContract: ContractSuite<Clock> = {
  port: 'Clock (@mentora/kernel)',
  cases: [
    {
      name: 'now() returns an Instant with a finite epochMillis number',
      verify: (clock: Clock): void => {
        const instant = clock.now();
        if (typeof instant.epochMillis !== 'number' || !Number.isFinite(instant.epochMillis)) {
          throw new InvariantViolationError('now().epochMillis must be a finite number');
        }
      },
    },
    {
      name: 'time is monotonic non-decreasing across consecutive reads',
      verify: (clock: Clock): void => {
        const first = clock.now();
        const second = clock.now();
        if (second.epochMillis < first.epochMillis) {
          throw new InvariantViolationError('now() must never go backwards');
        }
      },
    },
  ],
};
