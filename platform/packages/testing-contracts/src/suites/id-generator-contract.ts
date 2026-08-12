import type { IdGenerator } from '@mentora/kernel';
import { InvariantViolationError } from '@mentora/kernel';

import type { ContractSuite } from '../contract.js';

/**
 * The promises every `IdGenerator` implementation must keep. Note: uniqueness
 * within a run is a contract promise for production generators AND for
 * sequential/seeded test generators; a `ConstantIdGenerator` is deliberately
 * NOT a compliant IdGenerator for uniqueness — it trades the contract for
 * pinned assertions, and must not be verified with this suite.
 */
export const idGeneratorContract: ContractSuite<IdGenerator> = {
  port: 'IdGenerator (@mentora/kernel)',
  cases: [
    {
      name: 'generate() returns a non-empty string',
      verify: (gen: IdGenerator): void => {
        const id = gen.generate();
        if (typeof id !== 'string' || id.length === 0) {
          throw new InvariantViolationError('generate() must return a non-empty string');
        }
      },
    },
    {
      name: 'generate() does not repeat within 1000 calls',
      verify: (gen: IdGenerator): void => {
        const seen = new Set<string>();
        for (let i = 0; i < 1_000; i += 1) {
          const id = gen.generate();
          if (seen.has(id)) {
            throw new InvariantViolationError(`duplicate id after ${String(i)} calls: ${id}`);
          }
          seen.add(id);
        }
      },
    },
  ],
};
