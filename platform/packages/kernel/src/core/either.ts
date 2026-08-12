/**
 * `Either<L, R>` — the general two-branch sum type. `Result` is the specialized,
 * ergonomic form for success/failure (and should be preferred for that); `Either`
 * is here for the cases where neither side is "the error" — a genuine
 * left-or-right choice. Discriminated by `_tag`.
 */

export interface Left<L> {
  readonly _tag: 'Left';
  readonly left: L;
}

export interface Right<R> {
  readonly _tag: 'Right';
  readonly right: R;
}

export type Either<L, R> = Left<L> | Right<R>;

/** Construct a Left. */
export const left = <L>(value: L): Left<L> => ({ _tag: 'Left', left: value });

/** Construct a Right. */
export const right = <R>(value: R): Right<R> => ({ _tag: 'Right', right: value });

/** Type guard: Left. */
export const isLeft = <L, R>(either: Either<L, R>): either is Left<L> => either._tag === 'Left';

/** Type guard: Right. */
export const isRight = <L, R>(either: Either<L, R>): either is Right<R> => either._tag === 'Right';

/** Transform the Right value, leaving a Left untouched. */
export const mapEither = <L, R, U>(either: Either<L, R>, f: (value: R) => U): Either<L, U> =>
  either._tag === 'Right' ? right(f(either.right)) : either;

/** Transform the Left value, leaving a Right untouched. */
export const mapLeft = <L, R, F>(either: Either<L, R>, f: (value: L) => F): Either<F, R> =>
  either._tag === 'Left' ? left(f(either.left)) : either;

/** Fold both branches to a single value. */
export const matchEither = <L, R, U>(
  either: Either<L, R>,
  cases: { readonly left: (value: L) => U; readonly right: (value: R) => U },
): U => (either._tag === 'Left' ? cases.left(either.left) : cases.right(either.right));
