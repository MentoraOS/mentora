import type { Linter, Rule } from 'eslint';

import { RULE_CATALOG, catalogByName } from './catalog.js';
import { commandNaming } from './rules/command-naming.js';
import { eventNaming } from './rules/event-naming.js';
import { forbiddenVocabulary } from './rules/forbidden-vocabulary.js';
import { noDtoInDomain } from './rules/no-dto-in-domain.js';
import { noForbiddenSuffixes } from './rules/no-forbidden-suffixes.js';
import { noFrameworkImportInDomain } from './rules/no-framework-import-in-domain.js';
import { createSuffixRule } from './rules/suffix-rule-factory.js';

/**
 * @mentora/eslint-plugin-mentora — the Constitution's architecture laws as
 * executable lint rules. Every rule derives from the frozen R2 corpus and
 * carries a permanent MENTORA-code; nothing here is invented (rules without an
 * R2 source do not exist — that is the plugin's own constitution).
 */

export { RULE_CATALOG } from './catalog.js';
export type { RuleCatalogEntry } from './catalog.js';

const rules: Record<string, Rule.RuleModule> = {
  'forbidden-vocabulary': forbiddenVocabulary,
  'no-forbidden-suffixes': noForbiddenSuffixes,
  'event-naming': eventNaming,
  'command-naming': commandNaming,
  'query-naming': createSuffixRule(catalogByName('query-naming'), [
    { suffix: 'Query', minWordsBefore: 2, stemShape: '<Truth><Aspect>' },
  ]),
  'policy-naming': createSuffixRule(catalogByName('policy-naming'), [
    { suffix: 'Policy', minWordsBefore: 2, stemShape: '<Truth><Rule>' },
  ]),
  'specification-naming': createSuffixRule(catalogByName('specification-naming'), [
    { suffix: 'Specification', minWordsBefore: 1, stemShape: '<Question>' },
  ]),
  'repository-naming': createSuffixRule(catalogByName('repository-naming'), [
    { suffix: 'Repository', minWordsBefore: 1, stemShape: '<Truth>' },
  ]),
  'projection-naming': createSuffixRule(catalogByName('projection-naming'), [
    { suffix: 'Projection', minWordsBefore: 1, stemShape: '<Name>' },
    { suffix: 'ReadModel', minWordsBefore: 1, stemShape: '<Name>' },
  ]),
  'process-manager-naming': createSuffixRule(catalogByName('process-manager-naming'), [
    { suffix: 'Process', minWordsBefore: 1, stemShape: '<Journey>' },
  ]),
  'adapter-naming': createSuffixRule(catalogByName('adapter-naming'), [
    { suffix: 'Adapter', minWordsBefore: 2, stemShape: '<Provider><Capability>' },
  ]),
  'port-naming': createSuffixRule(catalogByName('port-naming'), [
    { suffix: 'Port', minWordsBefore: 1, stemShape: '<Capability>' },
  ]),
  'application-service-naming': createSuffixRule(catalogByName('application-service-naming'), [
    { suffix: 'ApplicationService', minWordsBefore: 1, stemShape: '<UseCase>' },
  ]),
  'exception-naming': createSuffixRule(catalogByName('exception-naming'), [
    { suffix: 'Exception', minWordsBefore: 2, stemShape: '<Truth><Reason>' },
  ]),
  'no-dto-in-domain': noDtoInDomain,
  'no-framework-import-in-domain': noFrameworkImportInDomain,
};

const plugin = { rules };

const allRules = (severity: 'warn' | 'error'): Linter.RulesRecord =>
  Object.fromEntries(Object.keys(rules).map((name) => [`mentora/${name}`, severity]));

const configBase = (ruleLevels: Linter.RulesRecord): Linter.Config[] => [
  {
    plugins: { mentora: plugin },
    rules: ruleLevels,
  },
];

/**
 * The four official configurations (flat config):
 * - `recommended` — every rule active as a warning: adoption mode.
 * - `strict` — every rule an error.
 * - `constitution` — every rule an error; the constitutional default for all
 *   Mentora packages. (Path-scoped rules use their R2 defaults; override the
 *   `files` option per repo layout if needed.)
 * - `enterprise` — constitution, plus the org may layer stricter options on
 *   top; today it equals constitution (no invented extra law — R2 rule).
 *
 * Import boundaries (I-1/I-12) are enforced by @mentora/eslint-config/boundaries;
 * compose both: [...mentora, ...boundaries, ...mentoraPlugin.configs.constitution].
 */
const configs: Record<string, Linter.Config[]> = {
  recommended: configBase(allRules('warn')),
  strict: configBase(allRules('error')),
  constitution: configBase(allRules('error')),
  enterprise: configBase(allRules('error')),
};

const pluginWithConfigs: {
  rules: Record<string, Rule.RuleModule>;
  configs: Record<string, Linter.Config[]>;
} = { rules, configs };

export default pluginWithConfigs;

/** Sanity: the catalog and the rule table must stay in one-to-one sync. */
export const catalogIsInSync = (): boolean =>
  RULE_CATALOG.length === Object.keys(rules).length &&
  RULE_CATALOG.every((entry) => entry.name in rules);
