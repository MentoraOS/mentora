import type { Rule } from 'eslint';

import type { RuleCatalogEntry } from '../catalog.js';
import { isPascalCase, wordsBeforeSuffix } from '../helpers.js';

import { metaFor, onDeclaredNames } from './shared.js';

/**
 * Factory for the building-block suffix rules (Repository, Policy, Query…).
 * One law shape, twelve applications — exactly like the Foundation's own
 * "une seule loi appliquée six fois".
 *
 * A declaration whose name ends with the suffix must be PascalCase and carry at
 * least `minWordsBefore` words before it (e.g. `<Truth><Rule>Policy` ⇒ 2).
 */
export interface SuffixSpec {
  readonly suffix: string;
  readonly minWordsBefore: number;
  /** What the stem must express, for the message (e.g. "<Truth><Rule>"). */
  readonly stemShape: string;
}

export const createSuffixRule = (
  entry: RuleCatalogEntry,
  specs: readonly SuffixSpec[],
): Rule.RuleModule => ({
  meta: metaFor(entry, {
    tooFewWords:
      'The name "{{name}}" must be {{shape}}{{suffix}} — at least {{min}} word(s) before "{{suffix}}".',
    notPascal: 'The name "{{name}}" must be PascalCase to follow {{shape}}{{suffix}}.',
  }),
  create(context) {
    return onDeclaredNames(({ name, node }) => {
      for (const spec of specs) {
        if (!name.endsWith(spec.suffix)) {
          continue;
        }
        // Longest-suffix wins is not needed: specs within a rule never overlap,
        // except ApplicationService vs Service handled by rule separation.
        if (!isPascalCase(name)) {
          context.report({
            node,
            messageId: 'notPascal',
            data: { name, shape: spec.stemShape, suffix: spec.suffix },
          });
          return;
        }
        const words = wordsBeforeSuffix(name, spec.suffix);
        if (words < spec.minWordsBefore) {
          context.report({
            node,
            messageId: 'tooFewWords',
            data: {
              name,
              shape: spec.stemShape,
              suffix: spec.suffix,
              min: String(spec.minWordsBefore),
            },
          });
        }
        return;
      }
    });
  },
});
