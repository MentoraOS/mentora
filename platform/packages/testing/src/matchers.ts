import type { Either, Option, Result } from '@mentora/kernel';
import { expect } from 'vitest';

/**
 * Custom Vitest matchers for the kernel's functional types. Registered by
 * importing `@mentora/testing/register` (or calling `registerMentoraMatchers`)
 * in a setup file.
 *
 * They make intent readable and failures precise:
 *   expect(result).toBeOkWith(42)
 *   expect(option).toBeNone()
 */

interface MatcherResult {
  readonly pass: boolean;
  readonly message: () => string;
}

/** The slice of Vitest's matcher context we rely on. */
interface MatcherContext {
  readonly equals: (a: unknown, b: unknown) => boolean;
}

const show = (value: unknown): string => JSON.stringify(value);

export const mentoraMatchers = {
  toBeOk(this: MatcherContext, received: Result<unknown, unknown>): MatcherResult {
    return {
      pass: received.ok,
      message: () =>
        received.ok
          ? `expected Result NOT to be Ok, but it was Ok(${show(received.value)})`
          : `expected Result to be Ok, but it was Err(${show(received.error)})`,
    };
  },
  toBeOkWith(this: MatcherContext, received: Result<unknown, unknown>, expected: unknown): MatcherResult {
    const pass = received.ok && this.equals(received.value, expected);
    return {
      pass,
      message: () =>
        pass
          ? `expected Result NOT to be Ok(${show(expected)})`
          : received.ok
            ? `expected Ok(${show(expected)}), got Ok(${show(received.value)})`
            : `expected Ok(${show(expected)}), got Err(${show(received.error)})`,
    };
  },
  toBeErr(this: MatcherContext, received: Result<unknown, unknown>): MatcherResult {
    return {
      pass: !received.ok,
      message: () =>
        received.ok
          ? `expected Result to be Err, but it was Ok(${show(received.value)})`
          : `expected Result NOT to be Err, but it was Err(${show(received.error)})`,
    };
  },
  toBeErrWith(this: MatcherContext, received: Result<unknown, unknown>, expected: unknown): MatcherResult {
    const pass = !received.ok && this.equals(received.error, expected);
    return {
      pass,
      message: () =>
        pass
          ? `expected Result NOT to be Err(${show(expected)})`
          : received.ok
            ? `expected Err(${show(expected)}), got Ok(${show(received.value)})`
            : `expected Err(${show(expected)}), got Err(${show(received.error)})`,
    };
  },
  toBeSomeWith(this: MatcherContext, received: Option<unknown>, expected: unknown): MatcherResult {
    const pass = received.some && this.equals(received.value, expected);
    return {
      pass,
      message: () =>
        pass
          ? `expected Option NOT to be Some(${show(expected)})`
          : received.some
            ? `expected Some(${show(expected)}), got Some(${show(received.value)})`
            : `expected Some(${show(expected)}), got None`,
    };
  },
  toBeNone(this: MatcherContext, received: Option<unknown>): MatcherResult {
    return {
      pass: !received.some,
      message: () =>
        received.some
          ? `expected None, got Some(${show(received.value)})`
          : `expected Option NOT to be None`,
    };
  },
  toBeRightWith(this: MatcherContext, received: Either<unknown, unknown>, expected: unknown): MatcherResult {
    const pass = received._tag === 'Right' && this.equals(received.right, expected);
    return {
      pass,
      message: () =>
        pass
          ? `expected Either NOT to be Right(${show(expected)})`
          : received._tag === 'Right'
            ? `expected Right(${show(expected)}), got Right(${show(received.right)})`
            : `expected Right(${show(expected)}), got Left(${show(received.left)})`,
    };
  },
  toBeLeftWith(this: MatcherContext, received: Either<unknown, unknown>, expected: unknown): MatcherResult {
    const pass = received._tag === 'Left' && this.equals(received.left, expected);
    return {
      pass,
      message: () =>
        pass
          ? `expected Either NOT to be Left(${show(expected)})`
          : received._tag === 'Left'
            ? `expected Left(${show(expected)}), got Left(${show(received.left)})`
            : `expected Left(${show(expected)}), got Right(${show(received.right)})`,
    };
  },
} as const;

/** Register the matchers with Vitest's expect. Call once (e.g. in a setup file). */
export const registerMentoraMatchers = (): void => {
  expect.extend(mentoraMatchers);
};

interface MentoraMatchers<R = unknown> {
  toBeOk: () => R;
  toBeOkWith: (expected: unknown) => R;
  toBeErr: () => R;
  toBeErrWith: (expected: unknown) => R;
  toBeSomeWith: (expected: unknown) => R;
  toBeNone: () => R;
  toBeRightWith: (expected: unknown) => R;
  toBeLeftWith: (expected: unknown) => R;
}

/* eslint-disable @typescript-eslint/no-empty-object-type, @typescript-eslint/no-explicit-any --
   interface merging with Vitest requires the exact original shapes (T = any). */
declare module 'vitest' {
  interface Assertion<T = any> extends MentoraMatchers<Assertion<T>> {}
  interface AsymmetricMatchersContaining extends MentoraMatchers {}
}
/* eslint-enable @typescript-eslint/no-empty-object-type, @typescript-eslint/no-explicit-any */
