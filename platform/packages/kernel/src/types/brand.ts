/**
 * Nominal ("branded") types. TypeScript is structural by default, so two
 * `string`s are interchangeable even when they mean different things (a user id
 * vs. an order id). A brand attaches a phantom tag so the compiler treats them
 * as distinct without any runtime cost.
 *
 * This is the code form of the Foundation's insistence that identity is opaque
 * and never confused (F3.1.99 §4).
 *
 * @example
 * type UserId = Brand<string, 'UserId'>;
 * type OrderId = Brand<string, 'OrderId'>;
 * const u = 'u_1' as UserId;
 * const o: OrderId = u; // compile error — brands differ
 */

declare const brandTag: unique symbol;

export type Brand<T, TBrand extends string> = T & {
  readonly [brandTag]: TBrand;
};
