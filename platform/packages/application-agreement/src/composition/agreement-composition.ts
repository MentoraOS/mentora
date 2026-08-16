import type {
  CommandCarrier,
  QueryDispatch as QueryDispatchType,
  ReadJournalPort,
  SequenceJournalPort,
} from '@mentora/application-kernel';
import { CommandDispatch, ReactionDispatch } from '@mentora/application-kernel';
import { AGREEMENT_COMMAND_TYPES } from '@mentora/contracts-agreement';
import type {
  AgreementCancellationPolicyParams,
  AgreementRepository,
  ReschedulePolicyParams,
} from '@mentora/domain-agreement';
import { AgreementCancellationPolicy, ReschedulePolicy } from '@mentora/domain-agreement';
import type { Clock, IdGenerator } from '@mentora/kernel';
import { invariant } from '@mentora/kernel';

import { agreementQueryDispatch } from '../query/dispatch/agreement-query-dispatch.js';
import type {
  AgreementReadRightsPort,
  AgreementStateReadPort,
} from '../query/ports/agreement-state-read.port.js';
import { AgreementStateQueryApplicationService } from '../query/services/agreement-state-query.application-service.js';
import { AcceptAgreementApplicationService } from '../services/accept-agreement.application-service.js';
import type { AgreementSequenceMachinery } from '../services/agreement-sequence.application-service.js';
import { CancelAgreementApplicationService } from '../services/cancel-agreement.application-service.js';
import { ConfirmAgreementApplicationService } from '../services/confirm-agreement.application-service.js';
import { ElapseAgreementApplicationService } from '../services/elapse-agreement.application-service.js';
import { LapseAgreementRequestApplicationService } from '../services/lapse-agreement-request.application-service.js';
import { RejectAgreementApplicationService } from '../services/reject-agreement.application-service.js';
import { RequestAgreementApplicationService } from '../services/request-agreement.application-service.js';
import { RescheduleAgreementApplicationService } from '../services/reschedule-agreement.application-service.js';

/**
 * THE COMPOSITION of the Agreement context — F4.4 §2, verbatim: the Root is
 * "le seul endroit du système où des types concrets existent. Il construit
 * les Policies (avec leurs paramètres produit), les Application Services,
 * …, les Dispatchers et leurs tables… Il ne construit JAMAIS les Aggregates
 * — les unités naissent par des actes (Factories)… le Root assemble la
 * machinerie sans état, jamais les vérités."
 *
 * PURE DEPENDENCY INJECTION: this module builds the WHOLE graph explicitly —
 * no service locator, no hidden singleton, no dynamic resolve, no container.
 * "La règle du regard" (I-2): above the Root, everything RECEIVES its
 * dependencies; nothing searches.
 *
 * The Root proper is UNIQUE PER EXECUTABLE (F4.4.99). No executable exists
 * yet (apps/ is empty; the adapters arrive in a later phase) — this module
 * is therefore the ASSEMBLY of the Agreement context: the future executable
 * Root calls `composeAgreement` with its real port implementations and its
 * validated configuration, and receives the complete, boot-validated graph.
 * Tests exercise it today with the in-memory doubles.
 */

/** What the executable's Root PROVIDES: implementations and configuration. */
export interface AgreementCompositionProviders {
  /** The ports — implemented by adapters BELOW (I-12: driven side). */
  readonly repository: AgreementRepository;
  readonly stateReadPort: AgreementStateReadPort;
  readonly readRightsPort: AgreementReadRightsPort;

  /** The machinery — injected, never ambient (A-6). */
  readonly clock: Clock;
  readonly idGenerator: IdGenerator;
  readonly commandJournal: SequenceJournalPort;
  readonly readJournal: ReadJournalPort;

  /** PRODUCT configuration (I-5): the published Policy parameters. */
  readonly product: {
    readonly reschedule: ReschedulePolicyParams;
    readonly cancellation: AgreementCancellationPolicyParams;
  };

  /** TECHNICAL configuration (I-5: "comment vite", bounded — M-8). */
  readonly technical?: {
    readonly commandMaxAttempts?: number;
  };
}

/** The complete, validated Agreement graph the composition yields. */
export interface AgreementAssembly {
  readonly commandDispatch: CommandDispatch;
  readonly queryDispatch: QueryDispatchType;
  readonly reactionDispatch: ReactionDispatch;
  readonly services: {
    readonly request: RequestAgreementApplicationService;
    readonly accept: AcceptAgreementApplicationService;
    readonly reject: RejectAgreementApplicationService;
    readonly confirm: ConfirmAgreementApplicationService;
    readonly reschedule: RescheduleAgreementApplicationService;
    readonly cancel: CancelAgreementApplicationService;
    readonly lapse: LapseAgreementRequestApplicationService;
    readonly elapse: ElapseAgreementApplicationService;
    readonly stateQuery: AgreementStateQueryApplicationService;
  };
  readonly policies: {
    readonly reschedule: ReschedulePolicy;
    readonly cancellation: AgreementCancellationPolicy;
  };
  readonly machinery: {
    readonly clock: Clock;
    readonly idGenerator: IdGenerator;
    readonly commandJournal: SequenceJournalPort;
    readonly readJournal: ReadJournalPort;
  };
}

export const composeAgreement = (providers: AgreementCompositionProviders): AgreementAssembly => {
  // ---- the Policies: built HERE with their injected PRODUCT parameters
  // (F4.1 §4: "construites … au démarrage (composition root), injectées ;
  // jamais instanciées en chemin").
  const reschedulePolicy = new ReschedulePolicy(providers.product.reschedule);
  const cancellationPolicy = new AgreementCancellationPolicy(providers.product.cancellation);

  // ---- ONE shared machinery for the whole command side (A-6: one clock;
  // A-10: one correlated journal), technical retry budget bounded (M-8).
  const machinery: AgreementSequenceMachinery = {
    clock: providers.clock,
    journal: providers.commandJournal,
    ...(providers.technical?.commandMaxAttempts !== undefined
      ? { maxAttempts: providers.technical.commandMaxAttempts }
      : {}),
  };
  const repository = providers.repository;

  // ---- the eight Application Services (A-1: one Command, one carrier).
  const services = {
    request: new RequestAgreementApplicationService({ repository }, machinery),
    accept: new AcceptAgreementApplicationService({ repository }, machinery),
    reject: new RejectAgreementApplicationService({ repository }, machinery),
    confirm: new ConfirmAgreementApplicationService({ repository }, machinery),
    reschedule: new RescheduleAgreementApplicationService(
      { repository, reschedulePolicy },
      machinery,
    ),
    cancel: new CancelAgreementApplicationService({ repository, cancellationPolicy }, machinery),
    lapse: new LapseAgreementRequestApplicationService({ repository }, machinery),
    elapse: new ElapseAgreementApplicationService({ repository }, machinery),
    stateQuery: new AgreementStateQueryApplicationService(
      { readPort: providers.stateReadPort, rightsPort: providers.readRightsPort },
      { journal: providers.readJournal },
    ),
  } as const;

  // ---- the Dispatchers AND THEIR TABLES (F4.4 §2) — closed, declared here.
  const commandCarriers: readonly CommandCarrier[] = [
    { commandType: 'RequestAgreement', execute: (input) => services.request.execute(input) },
    { commandType: 'AcceptAgreement', execute: (input) => services.accept.execute(input) },
    { commandType: 'RejectAgreement', execute: (input) => services.reject.execute(input) },
    { commandType: 'ConfirmAgreement', execute: (input) => services.confirm.execute(input) },
    { commandType: 'RescheduleAgreement', execute: (input) => services.reschedule.execute(input) },
    { commandType: 'CancelAgreement', execute: (input) => services.cancel.execute(input) },
    {
      commandType: 'LapseAgreementRequest',
      execute: (input) => services.lapse.execute(input),
    },
    { commandType: 'ElapseAgreement', execute: (input) => services.elapse.execute(input) },
  ];
  const commandDispatch = new CommandDispatch(commandCarriers);
  const queryDispatch = agreementQueryDispatch(services.stateQuery);

  // The reaction table is CLOSED AND EMPTY by constitutional state: no
  // Agreement reaction is ratified today (NoShowSettlementProcess is under
  // the 1C-5 STOP; the projections are under the 1C-6 STOP). Declaring any
  // subscription here would complete the Corpus — forbidden.
  const reactionDispatch = new ReactionDispatch([]);

  // ---- BOOT VALIDATION, fail closed (F4.4 §7: "chaque Command a son
  // porteur unique · chaque Query son lecteur … Une seule erreur = pas de
  // démarrage").
  const carried = new Set(commandDispatch.commandTypes);
  for (const commandType of AGREEMENT_COMMAND_TYPES) {
    invariant(
      carried.has(commandType),
      `ratified Command '${commandType}' has no carrier — pas de démarrage (F4.4 §7)`,
    );
  }
  invariant(
    carried.size === AGREEMENT_COMMAND_TYPES.length,
    'the command table carries something outside the ratified catalogue — pas de démarrage',
  );
  invariant(
    queryDispatch.queryTypes.length === 1 && queryDispatch.queryTypes[0] === 'AgreementStateQuery',
    'the query table must serve exactly the ONE ratified read (F3.3 §5)',
  );

  return {
    commandDispatch,
    queryDispatch,
    reactionDispatch,
    services,
    policies: { reschedule: reschedulePolicy, cancellation: cancellationPolicy },
    machinery: {
      clock: providers.clock,
      idGenerator: providers.idGenerator,
      commandJournal: providers.commandJournal,
      readJournal: providers.readJournal,
    },
  };
};
