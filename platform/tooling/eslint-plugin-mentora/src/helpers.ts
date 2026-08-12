/**
 * Pure helpers shared by every rule. No ESLint types here — just string logic,
 * unit-testable on its own.
 */

/** Split a camelCase / PascalCase identifier into its words. */
export const splitWords = (identifier: string): string[] => {
  const matches = identifier.match(/[A-Z]+(?![a-z])|[A-Z][a-z0-9]*|[a-z0-9]+/g);
  return matches ?? [];
};

/** Is the identifier PascalCase (starts uppercase, alphanumeric)? */
export const isPascalCase = (identifier: string): boolean =>
  /^[A-Z][A-Za-z0-9]*$/.test(identifier);

/** Number of PascalCase words before a given suffix (suffix must match). */
export const wordsBeforeSuffix = (identifier: string, suffix: string): number => {
  if (!identifier.endsWith(suffix)) {
    return -1;
  }
  const stem = identifier.slice(0, identifier.length - suffix.length);
  if (stem.length === 0) {
    return 0;
  }
  return splitWords(stem).length;
};

/** Does the identifier contain `word` as a whole camel-word (case-insensitive)? */
export const containsWord = (identifier: string, word: string): boolean =>
  splitWords(identifier).some((w) => w.toLowerCase() === word.toLowerCase());

/** Default heuristic for a French-corpus English past participle: ends in "ed". */
export const endsInEd = (word: string): boolean => /ed$/i.test(word);
