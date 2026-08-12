import { mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { dirname } from 'node:path';

/**
 * Golden-file (approval-test) helper. A test compares its output against a
 * committed "golden" file; regenerate deliberately with UPDATE_GOLDEN=1.
 *
 * Golden files make large, structured outputs reviewable in diffs — the test
 * form of "the catalogue is authoritative, never the number".
 */

/** Stable JSON serialization: sorted keys, 2-space indent, trailing newline. */
export const toStableJson = (value: unknown): string => {
  const sortKeys = (v: unknown): unknown => {
    if (Array.isArray(v)) {
      return v.map(sortKeys);
    }
    if (v !== null && typeof v === 'object') {
      const entries = Object.entries(v as Record<string, unknown>).sort(([a], [b]) =>
        a < b ? -1 : a > b ? 1 : 0,
      );
      return Object.fromEntries(entries.map(([k, val]) => [k, sortKeys(val)]));
    }
    return v;
  };
  return `${JSON.stringify(sortKeys(value), null, 2)}\n`;
};

export interface GoldenComparison {
  readonly matches: boolean;
  readonly expected: string | undefined;
  readonly actual: string;
  readonly updated: boolean;
}

/**
 * Compare `content` to the golden file at `path`. If UPDATE_GOLDEN=1 is set (or
 * the file does not exist AND update is allowed), the golden file is (re)written
 * and the comparison reports `updated: true`.
 */
export const compareToGoldenFile = (path: string, content: string): GoldenComparison => {
  const update = process.env['UPDATE_GOLDEN'] === '1';
  let expected: string | undefined;
  try {
    expected = readFileSync(path, 'utf8');
  } catch {
    expected = undefined;
  }
  if (update || expected === undefined) {
    mkdirSync(dirname(path), { recursive: true });
    writeFileSync(path, content, 'utf8');
    return { matches: true, expected: content, actual: content, updated: true };
  }
  return { matches: expected === content, expected, actual: content, updated: false };
};
