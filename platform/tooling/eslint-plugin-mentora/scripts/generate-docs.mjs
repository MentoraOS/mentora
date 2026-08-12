// Generates docs/rules/<CODE>.md from the rule catalog (single source of truth).
// Run after build: `pnpm build && pnpm docs:generate`. The docs are committed;
// a test asserts they stay in sync with the catalog.

import { mkdirSync, writeFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const here = dirname(fileURLToPath(import.meta.url));
const { RULE_CATALOG } = await import('../dist/index.js');

export const renderRuleDoc = (entry) =>
  [
    `# ${entry.code} — \`mentora/${entry.name}\``,
    '',
    `> ${entry.description}`,
    '',
    '## Justification',
    '',
    entry.justification,
    '',
    '## R2 reference (the law this rule executes)',
    '',
    entry.r2Reference,
    '',
    '## Valid',
    '',
    '```ts',
    ...entry.valid,
    '```',
    '',
    '## Invalid',
    '',
    '```ts',
    ...entry.invalid,
    '```',
    '',
    `*Permanent diagnostic code: \`${entry.code}\`. Codes are never renumbered, never reused.*`,
    '',
  ].join('\n');

const outDir = join(here, '..', 'docs', 'rules');
mkdirSync(outDir, { recursive: true });

let index = ['# Rule index', ''];
for (const entry of RULE_CATALOG) {
  writeFileSync(join(outDir, `${entry.code}.md`), renderRuleDoc(entry), 'utf8');
  index.push(`- [${entry.code}](rules/${entry.code}.md) — \`mentora/${entry.name}\`: ${entry.description}`);
}
writeFileSync(join(outDir, '..', 'INDEX.md'), index.join('\n') + '\n', 'utf8');

console.log(`generated ${RULE_CATALOG.length} rule docs + INDEX.md`);
