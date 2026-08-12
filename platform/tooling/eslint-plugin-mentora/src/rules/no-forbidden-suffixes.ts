import type { Rule } from 'eslint';

import { catalogByName } from '../catalog.js';
import { splitWords, wordsBeforeSuffix } from '../helpers.js';

import { metaFor, onDeclaredNames } from './shared.js';

/**
 * MENTORA0002 — no-forbidden-suffixes.
 *
 * The transverse banned name parts of F2.5 §9: Manager, Helper, Util(s), Impl,
 * Data, Info, Common, Shared as suffixes; Base-/Abstract- as prefixes; and the
 * bare generic `<Truth>Service` (two words). A qualified capability service —
 * `<Truth><Capability>Service`, three or more words — is legal (F2.5.2), and
 * `ApplicationService` is governed by MENTORA0013, not here.
 */

const entry = catalogByName('no-forbidden-suffixes');

const BANNED_SUFFIXES = ['Manager', 'Helper', 'Utils', 'Util', 'Impl', 'Data', 'Info', 'Common', 'Shared'] as const;
const BANNED_PREFIXES = ['Base', 'Abstract'] as const;

export const noForbiddenSuffixes: Rule.RuleModule = {
  meta: metaFor(entry, {
    bannedSuffix: 'The name "{{name}}" ends with the banned part "{{part}}" — knowledge must have a named home.',
    bannedPrefix: 'The name "{{name}}" starts with the banned prefix "{{part}}" — prefer the contract, never Base-/Abstract-.',
    bareService:
      'The name "{{name}}" is a bare generic Service — qualify the capability (<Truth><Capability>Service, e.g. AgreementSchedulingService).',
  }),
  create(context) {
    return onDeclaredNames(({ name, node }) => {
      for (const suffix of BANNED_SUFFIXES) {
        if (name.endsWith(suffix)) {
          context.report({ node, messageId: 'bannedSuffix', data: { name, part: suffix } });
          return;
        }
      }
      for (const prefix of BANNED_PREFIXES) {
        if (new RegExp(`^${prefix}[A-Z]`).test(name)) {
          context.report({ node, messageId: 'bannedPrefix', data: { name, part: prefix } });
          return;
        }
      }
      if (name.endsWith('Service') && !name.endsWith('ApplicationService')) {
        const totalWords = splitWords(name).length;
        const before = wordsBeforeSuffix(name, 'Service');
        if (before <= 1 && totalWords <= 2) {
          context.report({ node, messageId: 'bareService', data: { name } });
        }
      }
    });
  },
};
