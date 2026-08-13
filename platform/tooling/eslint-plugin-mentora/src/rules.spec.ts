import { RuleTester } from 'eslint';
import { describe, expect, it } from 'vitest';

import plugin, { RULE_CATALOG, catalogIsInSync } from './index.js';

/**
 * Every rule tested with positive AND negative cases, via ESLint's own
 * RuleTester (wired to Vitest). File-scoped rules are exercised with matching
 * and non-matching filenames.
 */

RuleTester.describe = describe;
RuleTester.it = it;
RuleTester.itOnly = it.only;

const tester = new RuleTester({
  languageOptions: { ecmaVersion: 2023, sourceType: 'module' },
});

const rule = (name: string) => {
  const r = plugin.rules[name];
  if (r === undefined) {
    throw new Error(`missing rule ${name}`);
  }
  return r;
};

describe('catalog integrity', () => {
  it('catalog and rule table are in one-to-one sync', () => {
    expect(catalogIsInSync()).toBe(true);
  });

  it('codes are unique, sequential-format, and never reused', () => {
    const codes = RULE_CATALOG.map((e) => e.code);
    expect(new Set(codes).size).toBe(codes.length);
    for (const code of codes) {
      expect(code).toMatch(/^MENTORA\d{4}$/);
    }
  });

  it('every entry cites an R2 source', () => {
    for (const entry of RULE_CATALOG) {
      expect(entry.r2Reference, entry.code).toMatch(/R2 /);
    }
  });
});

tester.run('mentora/forbidden-vocabulary', rule('forbidden-vocabulary'), {
  valid: [
    'class Agreement {}',
    'const person = 1;',
    'class AvailableFunds {}',
    // `allow` whitelists a ratified exception
    { code: 'class UserAgentParser {}', options: [{ allow: ['user'] }] },
  ],
  invalid: [
    { code: 'class Booking {}', errors: [{ messageId: 'forbiddenWord' }] },
    { code: 'const user = 1;', errors: [{ messageId: 'forbiddenWord' }] },
    { code: 'class WalletView {}', errors: [{ messageId: 'forbiddenWord' }] },
    { code: 'class RatingBar {}', errors: [{ messageId: 'forbiddenWord' }] },
    { code: 'function openChat() {}', errors: [{ messageId: 'forbiddenWord' }] },
    {
      code: 'class LegacyThing {}',
      options: [{ extra: ['legacy'] }],
      errors: [{ messageId: 'forbiddenWord' }],
    },
  ],
});

tester.run('mentora/no-forbidden-suffixes', rule('no-forbidden-suffixes'), {
  valid: [
    'class AgreementSchedulingService {}', // qualified capability service — legal (F2.5.2)
    'class AgreementFactory {}',
    'class OfferRepository {}',
    'class ConfirmAgreementApplicationService {}', // governed by MENTORA0013
  ],
  invalid: [
    { code: 'class AgreementManager {}', errors: [{ messageId: 'bannedSuffix' }] },
    { code: 'class DateHelper {}', errors: [{ messageId: 'bannedSuffix' }] },
    { code: 'class StringUtils {}', errors: [{ messageId: 'bannedSuffix' }] },
    { code: 'class AgreementRepositoryImpl {}', errors: [{ messageId: 'bannedSuffix' }] },
    { code: 'class BaseAggregate {}', errors: [{ messageId: 'bannedPrefix' }] },
    { code: 'class AbstractPolicy {}', errors: [{ messageId: 'bannedPrefix' }] },
    { code: 'class AgreementService {}', errors: [{ messageId: 'bareService' }] },
  ],
});

const eventFile = '/repo/packages/domain-engagement/src/events/agreement-confirmed.ts';
tester.run('mentora/event-naming', rule('event-naming'), {
  valid: [
    { code: 'class AgreementConfirmed {}', filename: eventFile },
    { code: 'class ConsentWithdrawn {}', filename: eventFile },
    { code: 'class SignalUndeliverable {}', filename: eventFile },
    { code: 'class ReviewStruck {}', filename: eventFile },
    // outside event files, the rule is silent
    { code: 'class NotAnEvent {}', filename: '/repo/src/other/thing.ts' },
    // custom irregular via option (Titre VII ratification)
    {
      code: 'class SuggestionShown {}',
      filename: eventFile,
      options: [{ extraParticiples: ['Shown'] }],
    },
  ],
  invalid: [
    { code: 'class ConfirmAgreement {}', filename: eventFile, errors: [{ messageId: 'notAFact' }] },
    { code: 'class AgreementState {}', filename: eventFile, errors: [{ messageId: 'notAFact' }] },
    { code: 'class Confirmed {}', filename: eventFile, errors: [{ messageId: 'tooFewWords' }] },
  ],
});

const commandFile = '/repo/packages/domain-engagement/src/commands/confirm-agreement.command.ts';
tester.run('mentora/command-naming', rule('command-naming'), {
  valid: [
    { code: 'class ConfirmAgreement {}', filename: commandFile },
    { code: 'class RequestPayout {}', filename: commandFile },
    { code: 'class NotACommand {}', filename: '/repo/src/other/thing.ts' },
  ],
  invalid: [
    { code: 'class SetAgreement {}', filename: commandFile, errors: [{ messageId: 'bannedVerb' }] },
    { code: 'class SaveAgreement {}', filename: commandFile, errors: [{ messageId: 'bannedVerb' }] },
    { code: 'class Confirm {}', filename: commandFile, errors: [{ messageId: 'tooFewWords' }] },
  ],
});

// The twelve suffix rules, sampled through the factory (2 rules exhaustively +
// each remaining rule with one valid and one invalid case).
tester.run('mentora/policy-naming', rule('policy-naming'), {
  valid: [
    'class AgreementCancellationPolicy {}',
    'class ReschedulePolicy {}', // ratified single-stem policy (F3.3 §6)
    'class ConfirmationPolicy {}',
    'class Unrelated {}',
  ],
  invalid: [{ code: 'const Policy = class {};', errors: [{ messageId: 'tooFewWords' }] }],
});

tester.run('mentora/adapter-naming', rule('adapter-naming'), {
  valid: ['class LivekitRoomAdapter {}', 'class StripeSettlementAdapter {}'],
  invalid: [
    { code: 'class StripeAdapter {}', errors: [{ messageId: 'tooFewWords' }] },
    { code: 'class Adapter {}', errors: [{ messageId: 'tooFewWords' }] },
  ],
});

tester.run('mentora/query-naming', rule('query-naming'), {
  valid: [
    'class ConsentValidityQuery {}',
    'class MembershipQuery {}', // F3.3 §5
    'const validateAgreementQuery = () => 1;', // camelCase helpers are not building blocks
  ],
  invalid: [{ code: 'const Query = class {};', errors: [{ messageId: 'tooFewWords' }] }],
});

tester.run('mentora/specification-naming', rule('specification-naming'), {
  valid: ['class PayableAmountSpecification {}'],
  invalid: [{ code: 'class Specification {}', errors: [{ messageId: 'tooFewWords' }] }],
});

tester.run('mentora/repository-naming', rule('repository-naming'), {
  valid: ['class AgreementRepository {}'],
  invalid: [{ code: 'class Repository {}', errors: [{ messageId: 'tooFewWords' }] }],
});

tester.run('mentora/projection-naming', rule('projection-naming'), {
  valid: ['class CalendarProjection {}', 'class AgendaReadModel {}'],
  invalid: [
    { code: 'class Projection {}', errors: [{ messageId: 'tooFewWords' }] },
    { code: 'class ReadModel {}', errors: [{ messageId: 'tooFewWords' }] },
  ],
});

tester.run('mentora/process-manager-naming', rule('process-manager-naming'), {
  valid: ['class ErasureProcess {}'],
  invalid: [{ code: 'class Process {}', errors: [{ messageId: 'tooFewWords' }] }],
});

tester.run('mentora/port-naming', rule('port-naming'), {
  valid: ['class SettlementPort {}'],
  invalid: [{ code: 'class Port {}', errors: [{ messageId: 'tooFewWords' }] }],
});

tester.run('mentora/application-service-naming', rule('application-service-naming'), {
  valid: ['class ConfirmAgreementApplicationService {}'],
  invalid: [{ code: 'class ApplicationService {}', errors: [{ messageId: 'tooFewWords' }] }],
});

tester.run('mentora/exception-naming', rule('exception-naming'), {
  valid: ['class DepositRetentionActiveException {}'],
  invalid: [{ code: 'class AgreementException {}', errors: [{ messageId: 'tooFewWords' }] }],
});

const domainFile = '/repo/packages/domain-engagement/src/agreement.ts';
tester.run('mentora/no-dto-in-domain', rule('no-dto-in-domain'), {
  valid: [
    { code: 'class AgreementPayload {}', filename: domainFile },
    { code: 'class AgreementDto {}', filename: '/repo/apps/app-api/src/edge.ts' }, // edges are free
  ],
  invalid: [
    { code: 'class AgreementDto {}', filename: domainFile, errors: [{ messageId: 'dtoInDomain' }] },
    { code: 'class AgreementDTO {}', filename: domainFile, errors: [{ messageId: 'dtoInDomain' }] },
  ],
});

tester.run('mentora/no-framework-import-in-domain', rule('no-framework-import-in-domain'), {
  valid: [
    { code: "import { ok } from '@mentora/kernel';", filename: domainFile },
    // outside the domain, frameworks are legal (adapters live there)
    { code: "import { Injectable } from '@nestjs/common';", filename: '/repo/packages/adapter-nest-api/src/x.ts' },
  ],
  invalid: [
    {
      code: "import { Injectable } from '@nestjs/common';",
      filename: domainFile,
      errors: [{ messageId: 'frameworkImport' }],
    },
    {
      code: "import { PrismaClient } from '@prisma/client';",
      filename: domainFile,
      errors: [{ messageId: 'frameworkImport' }],
    },
  ],
});

describe('configs', () => {
  it('exposes recommended, strict, constitution and enterprise', () => {
    for (const name of ['recommended', 'strict', 'constitution', 'enterprise']) {
      const config = plugin.configs[name];
      expect(config, name).toBeDefined();
      const ruleLevels = config?.[0]?.rules ?? {};
      expect(Object.keys(ruleLevels).length).toBe(RULE_CATALOG.length);
    }
  });

  it('recommended warns, the others error', () => {
    const level = (configName: string): unknown =>
      plugin.configs[configName]?.[0]?.rules?.['mentora/forbidden-vocabulary'];
    expect(level('recommended')).toBe('warn');
    expect(level('strict')).toBe('error');
    expect(level('constitution')).toBe('error');
    expect(level('enterprise')).toBe('error');
  });
});
