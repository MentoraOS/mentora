/** A single timed execution. */
export interface Measurement<T> {
  readonly value: T;
  readonly elapsedMillis: number;
}

/** Time a synchronous function with the high-resolution clock. */
export const measure = <T>(fn: () => T): Measurement<T> => {
  const start = performance.now();
  const value = fn();
  return { value, elapsedMillis: performance.now() - start };
};

/** Time an async function. */
export const measureAsync = async <T>(fn: () => Promise<T>): Promise<Measurement<T>> => {
  const start = performance.now();
  const value = await fn();
  return { value, elapsedMillis: performance.now() - start };
};
