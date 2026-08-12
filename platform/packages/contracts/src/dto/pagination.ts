/**
 * Technical pagination DTOs. These are *transport* shapes, not domain concepts —
 * a page of anything, described the same way everywhere. A read that returns a
 * `Page<T>` is still governed by R-C (its rights-holder is checked at the
 * dispatch); this type only standardizes the envelope.
 */

export type SortDirection = 'asc' | 'desc';

export interface Sort<TField extends string = string> {
  readonly field: TField;
  readonly direction: SortDirection;
}

export interface PageRequest {
  /** Maximum number of items to return. */
  readonly limit: number;
  /** Number of items to skip. */
  readonly offset: number;
}

export interface Page<T> {
  readonly items: readonly T[];
  /** Total count across all pages. */
  readonly total: number;
  readonly limit: number;
  readonly offset: number;
}
