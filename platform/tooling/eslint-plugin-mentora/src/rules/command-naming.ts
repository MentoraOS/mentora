import type { Rule } from 'eslint';

import { catalogByName } from '../catalog.js';
import { isPascalCase, splitWords } from '../helpers.js';

import { filenameMatches, metaFor, onDeclaredNames } from './shared.js';

/**
 * MENTORA0004 — command-naming.
 *
 * In command files, every exported declaration is an imperative act and must
 * read `<Verb><Truth>` (≥ 2 words). The generic storage verbs the dictionary
 * bans (Set, Save) are refused as leading verbs. NOTE: the dictionary also bans
 * "generic" Create/Update/Delete while ratifying specific uses
 * (CreateOrganization, UpdatePortfolio) — genericity is a semantic judgment the
 * Glossary owns, not a lint heuristic, so this rule deliberately does NOT guess
 * it (rules are never invented beyond R2).
 */

const entry = catalogByName('command-naming');

const BANNED_LEADING_VERBS = ['Set', 'Save'] as const;

const DEFAULT_FILES = ['/commands/', '\\.command\\.ts$'] as const;

interface Options {
  readonly files?: readonly string[];
}

export const commandNaming: Rule.RuleModule = {
  meta: metaFor(
    entry,
    {
      bannedVerb: 'The command "{{name}}" starts with the banned generic verb "{{verb}}" — name the business act.',
      tooFewWords: 'The command "{{name}}" must be <Verb><Truth> (≥ 2 words) — an act applies to a named truth.',
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
    const files = options.files ?? DEFAULT_FILES;
    if (!filenameMatches(context.filename, files)) {
      return {};
    }
    return onDeclaredNames(({ name, node }) => {
      if (!isPascalCase(name)) {
        return;
      }
      const words = splitWords(name);
      if (words.length < 2) {
        context.report({ node, messageId: 'tooFewWords', data: { name } });
        return;
      }
      const verb = words[0] as string;
      if ((BANNED_LEADING_VERBS as readonly string[]).includes(verb)) {
        context.report({ node, messageId: 'bannedVerb', data: { name, verb } });
      }
    });
  },
};
