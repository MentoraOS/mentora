import { describe, it } from 'vitest';

/**
 * The contract-suite machinery.
 *
 * A `ContractSuite<T>` is a named list of executable promises about a `T`.
 * `describeContract(suite, makeSubject)` registers them with Vitest against a
 * fresh subject per case. The same suite runs against every implementation of
 * the port — fake and real alike — which is what makes it a *contract* and not
 * just a unit test.
 */

/** One executable promise of the contract. Throw (or fail an expect) to reject. */
export interface ContractCase<T> {
  readonly name: string;
  readonly verify: (subject: T) => void | Promise<void>;
}

export interface ContractSuite<T> {
  readonly port: string;
  readonly cases: ReadonlyArray<ContractCase<T>>;
}

/** Register a contract suite with Vitest against a subject factory. */
export const describeContract = <T>(suite: ContractSuite<T>, makeSubject: () => T): void => {
  describe(`contract: ${suite.port}`, () => {
    for (const contractCase of suite.cases) {
      it(contractCase.name, async () => {
        await contractCase.verify(makeSubject());
      });
    }
  });
};

/**
 * Structural interface verification: assert an object exposes the expected
 * members with the expected typeof. Catches "implements the port in name only"
 * drift at test time (TypeScript catches it at compile time for *our* code;
 * this catches dynamically-built or foreign objects).
 */
export type ShapeSpec = Readonly<
  Record<string, 'function' | 'string' | 'number' | 'boolean' | 'object'>
>;

export const verifyShape = (subject: unknown, shape: ShapeSpec): string[] => {
  const problems: string[] = [];
  if (subject === null || typeof subject !== 'object') {
    return [`subject is not an object (got ${typeof subject})`];
  }
  const record = subject as Record<string, unknown>;
  for (const [member, expected] of Object.entries(shape)) {
    const actual = typeof record[member];
    if (actual !== expected) {
      problems.push(`expected .${member} to be a ${expected}, got ${actual}`);
    }
  }
  return problems;
};
