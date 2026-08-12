/**
 * A typed, framework-agnostic dependency-injection token.
 *
 * The platform's inner rings must not depend on a DI framework (F4.4 I-7), yet
 * they need to name the ports they require. A `Token<T>` is that name: a unique
 * symbol plus a phantom `T` binding it to the type it resolves. The composition
 * root (an app) adapts these tokens to its container (e.g. NestJS providers) —
 * the tokens themselves know nothing about any framework.
 */

declare const tokenType: unique symbol;

export interface Token<T> {
  readonly key: symbol;
  readonly description: string;
  /** Phantom — carries `T` at the type level only; never present at runtime. */
  readonly [tokenType]?: T;
}

/** Create a unique token that resolves to `T`. */
export const createToken = <T>(description: string): Token<T> => ({
  key: Symbol(description),
  description,
});
