import type { Rule } from 'eslint';

import { catalogByName } from '../catalog.js';
import { endsInEd, isPascalCase, splitWords } from '../helpers.js';

import { filenameMatches, metaFor, onDeclaredNames } from './shared.js';

/**
 * MENTORA0003 — event-naming.
 *
 * In event files, every exported declaration is a fact and must read
 * `<Truth><PastParticiple>` (F2.5 §4: "participe passé obligatoire"). The
 * irregular participles ratified by the corpus itself (Struck, Withdrawn, Kept,
 * Undeliverable — they appear in the frozen Event Dictionary) are accepted;
 * `extraParticiples` may add project-ratified ones (Titre VII).
 */

const entry = catalogByName('event-naming');

/** Irregular endings ratified by the frozen Event Dictionary. */
const RATIFIED_IRREGULARS = ['Struck', 'Withdrawn', 'Kept', 'Undeliverable'] as const;

const DEFAULT_FILES = ['/events/', '\\.event\\.ts$'] as const;

interface Options {
  readonly files?: readonly string[];
  readonly extraParticiples?: readonly string[];
}

export const eventNaming: Rule.RuleModule = {
  meta: metaFor(
    entry,
    {
      notAFact:
        'The event "{{name}}" must be <Truth><PastParticiple> — a fact constates (…ed, or a ratified irregular).',
      tooFewWords: 'The event "{{name}}" must name its truth: <Truth><PastParticiple> (≥ 2 words).',
    },
    [
      {
        type: 'object',
        properties: {
          files: { type: 'array', items: { type: 'string' } },
          extraParticiples: { type: 'array', items: { type: 'string' } },
        },
        additionalProperties: false,
      },
    ],
  ),
  create(context) {
    const options = (context.options[0] ?? {}) as Options;
    const files = options.files ?? DEFAULT_FILES;
    if (!filenameMatches(context.filename, files)) {
      return {};
    }
    const irregulars = [...RATIFIED_IRREGULARS, ...(options.extraParticiples ?? [])];
    return onDeclaredNames(({ name, node }) => {
      if (!isPascalCase(name)) {
        return; // lower-case helpers in an event file are not events.
      }
      const words = splitWords(name);
      if (words.length < 2) {
        context.report({ node, messageId: 'tooFewWords', data: { name } });
        return;
      }
      const lastWord = words[words.length - 1] as string;
      const isParticiple = endsInEd(lastWord) || irregulars.includes(lastWord);
      if (!isParticiple) {
        context.report({ node, messageId: 'notAFact', data: { name } });
      }
    });
  },
};
