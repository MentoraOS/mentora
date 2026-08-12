import type { Rule } from 'eslint';

import { catalogByName } from '../catalog.js';
import { splitWords } from '../helpers.js';

import { filenameMatches, metaFor, onDeclaredNames } from './shared.js';

/**
 * MENTORA0015 — no-dto-in-domain.
 *
 * "DTO interdits dans le domaine ; aux bords : `<X>Payload`" (F2.5 §9). Inside
 * domain packages, no declaration may carry the word Dto/DTO; the ratified edge
 * shape is a Payload.
 */

const entry = catalogByName('no-dto-in-domain');

const DEFAULT_DOMAIN_FILES = ['/packages/domain-[^/]+/'] as const;

interface Options {
  readonly files?: readonly string[];
}

export const noDtoInDomain: Rule.RuleModule = {
  meta: metaFor(
    entry,
    {
      dtoInDomain:
        'The name "{{name}}" carries "Dto" inside a domain package — DTOs are forbidden in the domain; at the edges the word is <X>Payload.',
    },
    [
      {
        type: 'object',
        properties: {
          files: { type: 'array', items: { type: 'string' } },
        },
        additionalProperties: false,
      },
    ],
  ),
  create(context) {
    const options = (context.options[0] ?? {}) as Options;
    const files = options.files ?? DEFAULT_DOMAIN_FILES;
    if (!filenameMatches(context.filename, files)) {
      return {};
    }
    return onDeclaredNames(({ name, node }) => {
      const words = splitWords(name).map((w) => w.toLowerCase());
      if (words.includes('dto')) {
        context.report({ node, messageId: 'dtoInDomain', data: { name } });
      }
    });
  },
};
