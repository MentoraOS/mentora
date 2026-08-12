/** Pure string helpers. */

/** True if the string is empty or only whitespace. */
export const isBlank = (value: string): boolean => value.trim().length === 0;

/** Upper-case the first character. */
export const capitalize = (value: string): string =>
  value.charAt(0).toUpperCase() + value.slice(1);

/** Truncate to `maxLength`, appending `suffix` (counted within the limit). */
export const truncate = (value: string, maxLength: number, suffix = '…'): string => {
  if (value.length <= maxLength) {
    return value;
  }
  const cut = Math.max(0, maxLength - suffix.length);
  return value.slice(0, cut) + suffix;
};

/** Ensure the string starts with `prefix`. */
export const ensurePrefix = (value: string, prefix: string): string =>
  value.startsWith(prefix) ? value : prefix + value;

/** Ensure the string ends with `suffix`. */
export const ensureSuffix = (value: string, suffix: string): string =>
  value.endsWith(suffix) ? value : value + suffix;
