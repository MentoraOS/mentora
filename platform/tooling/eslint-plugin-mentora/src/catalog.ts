/**
 * THE RULE CATALOG — the single source of truth of Engineering Governance.
 *
 * Every rule has a PERMANENT diagnostic code (MENTORA0001…), a description, an
 * exact R2 reference (the constitutional chapter that owns the law — rules are
 * NEVER invented here), and valid/invalid examples. Rules, generated docs and
 * tests all derive from this catalog; nothing is written twice.
 *
 * Codes are never renumbered and never reused (the same discipline as the
 * Vocabulary Diff's VD-NNNN identifiers).
 */

export interface RuleCatalogEntry {
  /** Permanent diagnostic code. Never changes, never reused. */
  readonly code: string;
  /** ESLint rule name (kebab-case, without the plugin prefix). */
  readonly name: string;
  /** One-sentence description of what the rule enforces. */
  readonly description: string;
  /** Why the rule exists — the constitutional rationale. */
  readonly justification: string;
  /** The R2 source that owns this law (chapter + section). */
  readonly r2Reference: string;
  /** Identifiers / snippets the rule accepts. */
  readonly valid: readonly string[];
  /** Identifiers / snippets the rule rejects. */
  readonly invalid: readonly string[];
}

export const RULE_CATALOG: readonly RuleCatalogEntry[] = [
  {
    code: 'MENTORA0001',
    name: 'forbidden-vocabulary',
    description:
      'Forbids the banned words of the official Glossary (Booking, User, Wallet, Rating…) in declaration names.',
    justification:
      'One concept, one word: the forbidden vocabulary is law, and a banned word in code is lexical drift the Constitution forbids.',
    r2Reference:
      'R2 source/constitution/04-bilingual-dictionary.md §10 (Forbidden Vocabulary) · projection/glossary/02-vocabulary-diff.md VD-0066→VD-0082 · F2.9 P16',
    valid: ['class Agreement {}', 'const person = 1;', 'class AvailableFunds {}'],
    invalid: ['class Booking {}', 'const user = 1;', 'class WalletView {}', 'class RatingBar {}'],
  },
  {
    code: 'MENTORA0002',
    name: 'no-forbidden-suffixes',
    description:
      'Forbids the transverse banned name parts: -Manager, -Helper, -Util(s), -Impl, -Data, -Info, -Common, -Shared suffixes, Base-/Abstract- prefixes, and the bare generic -Service.',
    justification:
      'A Manager/Helper/Util is knowledge without a home; a bare <Truth>Service is a catch-all. A qualified capability service (<Truth><Capability>Service) remains legal (F2.5.2).',
    r2Reference:
      'R2 source/constitution/04-bilingual-dictionary.md §9 (interdits transverses) + F2.5.2 clarification · source/domain/01-tactical-building-blocks.md (Naming Constitution)',
    valid: [
      'class AgreementSchedulingService {}',
      'class AgreementFactory {}',
      'class OfferRepository {}',
    ],
    invalid: [
      'class AgreementManager {}',
      'class DateHelper {}',
      'class StringUtils {}',
      'class AgreementServiceImpl {}',
      'class AgreementService {}',
      'class BaseAggregate {}',
    ],
  },
  {
    code: 'MENTORA0003',
    name: 'event-naming',
    description:
      'In event files (events/ directories, *.event.ts), every exported PascalCase declaration must be <Truth><PastParticiple> (…ed, or a ratified irregular: Struck, Withdrawn, Kept, Undeliverable).',
    justification:
      'A fact is a constatation: the past participle is mandatory ("préfixe = propriétaire, participe passé obligatoire"). AgreementUpdated-style state events and -Created for business facts are dead.',
    r2Reference:
      'R2 source/constitution/04-bilingual-dictionary.md §4 (Event Dictionary) · source/domain/01-tactical-building-blocks.md (Domain Event)',
    valid: ['AgreementConfirmed', 'ReviewPublished', 'ConsentWithdrawn', 'SignalUndeliverable'],
    invalid: ['ConfirmAgreement', 'AgreementConfirm', 'AgreementState'],
  },
  {
    code: 'MENTORA0004',
    name: 'command-naming',
    description:
      'In command files (commands/ directories, *.command.ts), every exported declaration must be <Verb><Truth> (at least two words) and never start with the banned generics Set/Save.',
    justification:
      'A command is an imperative verb applied to a truth, always refusable. Set/Save are storage verbs, not business acts; a one-word command names no truth.',
    r2Reference: 'R2 source/constitution/04-bilingual-dictionary.md §5 (Command Dictionary, interdits)',
    valid: ['ConfirmAgreement', 'RequestPayout', 'DismissSuggestion'],
    invalid: ['SetAgreement', 'SaveAgreement', 'Confirm'],
  },
  {
    code: 'MENTORA0005',
    name: 'query-naming',
    description: 'Declarations ending in Query must be <Truth><Aspect>Query (≥ 2 words before the suffix).',
    justification: 'A read is a contract with a named truth and aspect, never an anonymous fetch.',
    r2Reference: 'R2 source/constitution/04-bilingual-dictionary.md §9 (Queries `<Truth><Aspect>Query`)',
    valid: ['ConsentValidityQuery', 'AgreementStateQuery'],
    invalid: ['DataQuery', 'Query'],
  },
  {
    code: 'MENTORA0006',
    name: 'policy-naming',
    description: 'Declarations ending in Policy must be <Truth><Rule>Policy (≥ 2 words before the suffix).',
    justification: 'A policy is a published rule about a named truth; a bare XPolicy names no rule.',
    r2Reference: 'R2 source/constitution/04-bilingual-dictionary.md §9 (Policies `<Truth><Rule>Policy`)',
    valid: ['AgreementCancellationPolicy', 'ConsentDefinitivenessPolicy'],
    invalid: ['AgreementPolicy', 'Policy'],
  },
  {
    code: 'MENTORA0007',
    name: 'specification-naming',
    description: 'Declarations ending in Specification must carry a named question (≥ 1 word before the suffix).',
    justification: 'A Specification is a named, composable business predicate — never anonymous.',
    r2Reference:
      'R2 source/domain/01-tactical-building-blocks.md (Specification, Naming Constitution `<Question>Specification`)',
    valid: ['DismissedSuggestionSpecification', 'PayableAmountSpecification'],
    invalid: ['Specification'],
  },
  {
    code: 'MENTORA0008',
    name: 'repository-naming',
    description: 'Declarations ending in Repository must be <Truth>Repository (≥ 1 word before the suffix).',
    justification: 'A repository is the registry of exactly one truth; a nameless Repository guards nothing.',
    r2Reference: 'R2 source/constitution/04-bilingual-dictionary.md §9 (Repositories `<Truth>Repository`)',
    valid: ['AgreementRepository', 'ConsentLedgerRepository'],
    invalid: ['Repository'],
  },
  {
    code: 'MENTORA0009',
    name: 'projection-naming',
    description:
      'Declarations ending in Projection must be <Name>Projection and those ending in ReadModel must be <Name>ReadModel (≥ 1 word before the suffix).',
    justification: 'A projection/read model is a named, recalculable derivation — never anonymous.',
    r2Reference:
      'R2 source/constitution/04-bilingual-dictionary.md §9 (Projections `<Name>Projection`, Read Models `<Name>ReadModel`)',
    valid: ['AgreementHonoredProjection', 'CalendarProjection', 'AgendaReadModel'],
    invalid: ['Projection', 'ReadModel'],
  },
  {
    code: 'MENTORA0010',
    name: 'process-manager-naming',
    description: 'Declarations ending in Process must be <Journey>Process (≥ 1 word before the suffix).',
    justification: 'A Process Manager is a named transverse journey (e.g. ErasureProcess), never a generic engine.',
    r2Reference: 'R2 source/constitution/04-bilingual-dictionary.md §9 (Process Managers `<Journey>Process`)',
    valid: ['ErasureProcess'],
    invalid: ['Process'],
  },
  {
    code: 'MENTORA0011',
    name: 'adapter-naming',
    description: 'Declarations ending in Adapter must be <Provider><Capability>Adapter (≥ 2 words before the suffix).',
    justification:
      'An adapter serves one frontier for one provider; provider names appear at the Adapter rank and nowhere else.',
    r2Reference: 'R2 source/constitution/04-bilingual-dictionary.md §9 (Adapters `<Provider><Capability>Adapter`)',
    valid: ['LivekitRoomAdapter', 'StripeSettlementAdapter'],
    invalid: ['StripeAdapter', 'Adapter'],
  },
  {
    code: 'MENTORA0012',
    name: 'port-naming',
    description: 'Declarations ending in Port must be <Capability>Port (≥ 1 word before the suffix).',
    justification: 'A port names the capability its consumer commands, never the technology behind it.',
    r2Reference: 'R2 source/constitution/04-bilingual-dictionary.md §9 (Ports `<Capability>Port`)',
    valid: ['SettlementPort', 'SignalDeliveryPort'],
    invalid: ['Port'],
  },
  {
    code: 'MENTORA0013',
    name: 'application-service-naming',
    description: 'Declarations ending in ApplicationService must be <UseCase>ApplicationService (≥ 1 word before the suffix).',
    justification: 'One use case = one Command = one Application Service; the name carries the use case.',
    r2Reference:
      'R2 source/constitution/04-bilingual-dictionary.md §9 (Application Services `<UseCase>ApplicationService`) · source/application/01-application-core-sequence.md §8',
    valid: ['ConfirmAgreementApplicationService'],
    invalid: ['ApplicationService'],
  },
  {
    code: 'MENTORA0014',
    name: 'exception-naming',
    description: 'Declarations ending in Exception must be <Truth><Reason>Exception (≥ 2 words before the suffix).',
    justification: 'An Exception refuses a malformed call about a named truth for a named reason.',
    r2Reference:
      'R2 source/domain/01-tactical-building-blocks.md (Domain Errors, Naming `<Truth><Reason>Exception`) · F2.5.2 (DepositRetentionActiveException)',
    valid: ['DepositRetentionActiveException', 'AgreementConditionsMissingException'],
    invalid: ['AgreementException', 'Exception'],
  },
  {
    code: 'MENTORA0015',
    name: 'no-dto-in-domain',
    description: 'Forbids Dto/DTO in declaration names inside domain packages; at the edges the ratified word is <X>Payload.',
    justification: 'DTOs are forbidden in the domain; the edge shape is a Payload.',
    r2Reference: 'R2 source/constitution/04-bilingual-dictionary.md §9 (« DTO interdits dans le domaine ; aux bords `<X>Payload` »)',
    valid: ['class AgreementPayload {}'],
    invalid: ['class AgreementDto {}', 'class AgreementDTO {}'],
  },
  {
    code: 'MENTORA0016',
    name: 'no-framework-import-in-domain',
    description: 'Forbids framework/vendor imports (NestJS, Prisma, TypeORM, Express…) inside domain packages.',
    justification:
      'The domain compiles no framework import; foreign types die at the Adapters. The domain must survive every vendor.',
    r2Reference:
      'R2 source/application/04-infrastructure-composition-runtime.md I-7 (« aucun import de framework dans le domaine ; tout est scanné ») · F4.1 A-9',
    valid: ["import { ok } from '@mentora/kernel';"],
    invalid: ["import { Injectable } from '@nestjs/common';", "import { PrismaClient } from '@prisma/client';"],
  },
] as const;

/** Look up a catalog entry by rule name. Throws if unknown (programmer error). */
export const catalogByName = (name: string): RuleCatalogEntry => {
  const entry = RULE_CATALOG.find((e) => e.name === name);
  if (entry === undefined) {
    throw new Error(`Unknown rule name: ${name}`);
  }
  return entry;
};
