import type { UnknownRecord } from '@mentora/kernel';

/** Local plain-object guard (kept dependency-light for the wire layer). */
export const isPlainObject = (value: unknown): value is UnknownRecord => {
  if (typeof value !== 'object' || value === null || Array.isArray(value)) {
    return false;
  }
  const proto: unknown = Object.getPrototypeOf(value);
  return proto === Object.prototype || proto === null;
};
