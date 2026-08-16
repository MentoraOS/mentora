import { invariant } from '@mentora/kernel';

/**
 * RelayRetryEngine — TECHNICAL, never business (M-8 verbatim: "les retries
 * sont bornés, avec backoff — le retry infini est un anti-pattern").
 * Exponential backoff, capped, plus jitter from an INJECTED source (never
 * ambient randomness — deterministic in specs). Deliberately NOT named a
 * Policy: the Policy block is the published product rule (F3.1); a retry
 * budget is "comment vite" (I-5).
 */

export type JitterSource = (boundMillis: number) => number;

export const cryptoJitterSource: JitterSource = (boundMillis) => {
  if (boundMillis <= 0) {
    return 0;
  }
  const buffer = new Uint32Array(1);
  globalThis.crypto.getRandomValues(buffer);
  return (buffer[0] ?? 0) % boundMillis;
};

export interface RelayRetryOptions {
  readonly baseDelayMillis: number;
  readonly maxDelayMillis: number;
  /** The bounded budget (M-8): total delivery attempts before quarantine. */
  readonly maxAttempts: number;
  readonly jitterMillis: number;
}

export class RelayRetryEngine {
  constructor(
    private readonly options: RelayRetryOptions,
    private readonly jitter: JitterSource = cryptoJitterSource,
  ) {
    invariant(options.maxAttempts >= 1, 'the budget carries at least one attempt (M-8: bounded)');
    invariant(options.baseDelayMillis >= 0 && options.maxDelayMillis >= options.baseDelayMillis, 'delays are ordered');
  }

  /** True when the budget is spent — the envelope's road ends in quarantine. */
  exhausted(attemptsSoFar: number): boolean {
    return attemptsSoFar >= this.options.maxAttempts;
  }

  /** Backoff for the NEXT try after `attemptsSoFar` failures: base·2^(n−1), capped, + jitter. */
  delayForMillis(attemptsSoFar: number): number {
    invariant(attemptsSoFar >= 1, 'a delay follows a failed attempt');
    const exponential = this.options.baseDelayMillis * 2 ** (attemptsSoFar - 1);
    const capped = Math.min(exponential, this.options.maxDelayMillis);
    return capped + this.jitter(this.options.jitterMillis);
  }
}
