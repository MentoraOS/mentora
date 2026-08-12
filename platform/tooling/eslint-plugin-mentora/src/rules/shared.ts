import type { Rule } from 'eslint';

import type { RuleCatalogEntry } from '../catalog.js';

/**
 * Shared rule plumbing: a declaration-name visitor (one place that knows which
 * AST nodes declare a name) and the meta builder that stamps every rule with
 * its permanent diagnostic code and R2 reference.
 */

export interface NamedDeclaration {
  readonly name: string;
  readonly node: Rule.Node;
}

/** Build a visitor that calls `cb` for every declared name in the file. */
export const onDeclaredNames = (cb: (decl: NamedDeclaration) => void): Rule.RuleListener => {
  const fromId = (node: Rule.Node & { id?: unknown }): void => {
    const id = node.id as { type?: string; name?: string } | null | undefined;
    if (id && id.type === 'Identifier' && typeof id.name === 'string') {
      cb({ name: id.name, node });
    }
  };
  return {
    ClassDeclaration: fromId,
    FunctionDeclaration: fromId,
    VariableDeclarator: fromId,
    TSInterfaceDeclaration: fromId,
    TSTypeAliasDeclaration: fromId,
    TSEnumDeclaration: fromId,
  };
};

/** Standard meta for a catalog-backed rule. The message always carries the code. */
export const metaFor = (
  entry: RuleCatalogEntry,
  messages: Record<string, string>,
  schema: Rule.RuleMetaData['schema'] = [],
): Rule.RuleMetaData => ({
  type: 'problem',
  docs: {
    description: `${entry.code}: ${entry.description}`,
    url: `https://mentora.local/eslint-plugin-mentora/docs/rules/${entry.code}.md`,
  },
  schema,
  messages: Object.fromEntries(
    Object.entries(messages).map(([id, text]) => [id, `[${entry.code}] ${text} (${entry.r2Reference})`]),
  ),
});

/** Does the (normalized) filename match any of the regex sources? */
export const filenameMatches = (filename: string, regexSources: readonly string[]): boolean => {
  const normalized = filename.replace(/\\/g, '/');
  return regexSources.some((source) => new RegExp(source).test(normalized));
};
