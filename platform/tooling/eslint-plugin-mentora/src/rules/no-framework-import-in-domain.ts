import type { Rule } from 'eslint';

import { catalogByName } from '../catalog.js';

import { filenameMatches, metaFor } from './shared.js';

/**
 * MENTORA0016 — no-framework-import-in-domain.
 *
 * F4.4 I-7: "aucun import de framework dans le domaine ; tout est scanné".
 * Inside domain packages, importing a framework or vendor SDK is an error —
 * foreign types die at the Adapters. The law is R2's; the package list is
 * configuration (the law names no vendor, deliberately).
 */

const entry = catalogByName('no-framework-import-in-domain');

const DEFAULT_DOMAIN_FILES = ['/packages/domain-[^/]+/'] as const;

/** Default frameworks/vendors — regex sources matched against import specifiers. */
const DEFAULT_FORBIDDEN_IMPORTS = [
  '^@nestjs/',
  '^prisma$',
  '^@prisma/',
  '^typeorm$',
  '^express$',
  '^fastify$',
  '^amqplib$',
  '^ioredis$',
  '^redis$',
  '^@opensearch-project/',
  '^minio$',
  '^rxjs',
] as const;

interface Options {
  readonly files?: readonly string[];
  readonly forbiddenImports?: readonly string[];
}

export const noFrameworkImportInDomain: Rule.RuleModule = {
  meta: metaFor(
    entry,
    {
      frameworkImport:
        'The domain must not import "{{source}}" — no framework import in the domain; foreign types die at the Adapters.',
    },
    [
      {
        type: 'object',
        properties: {
          files: { type: 'array', items: { type: 'string' } },
          forbiddenImports: { type: 'array', items: { type: 'string' } },
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
    const forbidden = (options.forbiddenImports ?? DEFAULT_FORBIDDEN_IMPORTS).map(
      (source) => new RegExp(source),
    );
    return {
      ImportDeclaration(node) {
        const source = node.source.value;
        if (typeof source === 'string' && forbidden.some((re) => re.test(source))) {
          context.report({ node, messageId: 'frameworkImport', data: { source } });
        }
      },
    };
  },
};
