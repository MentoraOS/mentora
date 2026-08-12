import { readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

import { describe, expect, it } from 'vitest';

import { RULE_CATALOG } from './catalog.js';

/**
 * The generated documentation must stay in sync with the catalog: one file per
 * permanent code, each containing its code, rule name and R2 reference. If a
 * rule is added without regenerating docs (`pnpm build && pnpm docs:generate`),
 * this suite fails.
 */

const docsDir = join(dirname(fileURLToPath(import.meta.url)), '..', 'docs');

describe('generated docs', () => {
  it('every catalog entry has its documentation file, carrying code + R2 ref', () => {
    for (const entry of RULE_CATALOG) {
      const path = join(docsDir, 'rules', `${entry.code}.md`);
      const content = readFileSync(path, 'utf8');
      expect(content, entry.code).toContain(entry.code);
      expect(content, entry.code).toContain(`mentora/${entry.name}`);
      expect(content, entry.code).toContain(entry.r2Reference);
    }
  });

  it('the index lists every code', () => {
    const index = readFileSync(join(docsDir, 'INDEX.md'), 'utf8');
    for (const entry of RULE_CATALOG) {
      expect(index).toContain(entry.code);
    }
  });
});
