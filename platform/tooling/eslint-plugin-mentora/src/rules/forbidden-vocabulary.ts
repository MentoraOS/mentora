import type { Rule } from 'eslint';

import { catalogByName } from '../catalog.js';
import { containsWord } from '../helpers.js';

import { metaFor, onDeclaredNames } from './shared.js';

/**
 * MENTORA0001 — forbidden-vocabulary.
 *
 * The banned words of the official Glossary (F2.5 §10, Vocabulary Diff
 * VD-0066→VD-0082) may not appear as words inside declaration names. The default
 * list is the ratified one; `allow` whitelists project-approved uses, `extra`
 * adds bans — the LIST comes from R2, only its application is configurable.
 */

const entry = catalogByName('forbidden-vocabulary');

/** The ratified forbidden words with their official replacements (VD refs). */
export const FORBIDDEN_WORDS: Readonly<Record<string, string>> = {
  booking: 'Agreement (VD-0066)',
  reservation: 'Agreement (VD-0066)',
  appointment: 'Agreement (VD-0066)',
  meeting: 'Encounter (VD-0067)',
  call: 'Encounter (VD-0067)',
  user: 'Person (VD-0068)',
  wallet: 'AvailableFunds (VD-0069)',
  withdrawal: 'Payout (VD-0069)',
  rating: 'forbidden — RT-03 (VD-0070)',
  score: 'forbidden — RT-03 (VD-0070)',
  chat: 'Conversation (VD-0071)',
  thread: 'Conversation (VD-0071)',
  inbox: 'Conversation (VD-0071)',
  feed: 'forbidden surface word (VD-0071)',
  login: 'Entry (VD-0071)',
  ticket: 'SupportRequest (VD-0071)',
  replica: 'an instance / InstanceId (VD-0073)',
};

interface Options {
  readonly allow?: readonly string[];
  readonly extra?: readonly string[];
}

export const forbiddenVocabulary: Rule.RuleModule = {
  meta: metaFor(
    entry,
    {
      forbiddenWord:
        'The word "{{word}}" in "{{name}}" is forbidden vocabulary; the official term is {{replacement}}.',
    },
    [
      {
        type: 'object',
        properties: {
          allow: { type: 'array', items: { type: 'string' } },
          extra: { type: 'array', items: { type: 'string' } },
        },
        additionalProperties: false,
      },
    ],
  ),
  create(context) {
    const options = (context.options[0] ?? {}) as Options;
    const allow = new Set((options.allow ?? []).map((w) => w.toLowerCase()));
    const banned = new Map<string, string>(
      Object.entries(FORBIDDEN_WORDS).filter(([word]) => !allow.has(word)),
    );
    for (const extraWord of options.extra ?? []) {
      banned.set(extraWord.toLowerCase(), 'project-banned (extra)');
    }
    return onDeclaredNames(({ name, node }) => {
      for (const [word, replacement] of banned) {
        if (containsWord(name, word)) {
          context.report({
            node,
            messageId: 'forbiddenWord',
            data: { word, name, replacement },
          });
          return;
        }
      }
    });
  },
};
