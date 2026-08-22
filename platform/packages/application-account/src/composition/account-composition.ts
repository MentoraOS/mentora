import type {
  CommandCarrier,
  QueryDispatch,
  ReactionDispatch,
  ReactionJournalPort,
  ReadJournalPort,
  SequenceInput,
  SequenceJournalPort,
  SequenceOutcome,
  SequenceRefusalLike,
} from '@mentora/application-kernel';
import { CommandDispatch } from '@mentora/application-kernel';
import type { ActorRef, CorrelationId } from '@mentora/contracts';
import type { StartSubscription as StartSubscriptionWire } from '@mentora/contracts-account';
import { ACCOUNT_COMMAND_TYPES, ACCOUNT_QUERY_TYPES } from '@mentora/contracts-account';
import type {
  AccountRepository,
  AvailabilityFrameRepository,
  ReachabilityPolicyParams,
  Subscription,
  SubscriptionPolicyParams,
  SubscriptionRepository,
  SupportRequestRepository,
} from '@mentora/domain-account';
import { ReachabilityPolicy, SubscriptionPolicy } from '@mentora/domain-account';
import type { Clock } from '@mentora/kernel';
import { invariant } from '@mentora/kernel';

import { DEVELOPMENT_NO_SETTLEMENT } from '../acl/development-no-settlement-adapter.js';
import type { SettlementAclPort } from '../acl/settlement-acl.port.js';
import type { ChoreographyStorePort } from '../reactions/account-choreography.js';
import { accountReactionDispatch, CHOREOGRAPHY_FACT_TYPES } from '../reactions/account-choreography.js';
import type { AccountReadRightsPort, AvailabilityFrameReadPort, ReachabilityReadPort } from '../read/ports/account-read.port.js';
import {
  accountQueryDispatch,
  AvailabilityFrameQueryApplicationService,
  ReachabilityQueryApplicationService,
} from '../read/services/account-query-services.js';
import type { AccountSequenceMachinery } from '../services/account-application-services.js';
import {
  ChangeAvailabilityFrameApplicationService,
  ChangePreferenceApplicationService,
  ChangeReachabilityApplicationService,
  CloseAccountApplicationService,
  EndSubscriptionApplicationService,
  HandleSupportRequestApplicationService,
  OpenSupportRequestApplicationService,
  RegisterDeviceApplicationService,
  RegisterPersonApplicationService,
  RemoveDeviceApplicationService,
  StartSubscriptionApplicationService,
} from '../services/account-application-services.js';

/**
 * THE COMPOSITION of the Account context — F4.4 §2, the reference shape
 * (composeIdentityAccess). Pure DI, tables CLOSED and compared to the
 * catalogues at boot (fail closed): eleven carriers ≡ catalogue 36-46, two
 * readers ≡ lectures n°4/n°10, four consumed inputs ≡ the declared
 * choreography (RFC-003 P3/P4), ONE Settlement ACL adapter whose name is
 * read and whose PROVISIONAL development form is refused outside
 * development (CTO order, Sprint 7).
 */

export interface AccountCompositionProviders {
  readonly accountRepository: AccountRepository;
  readonly availabilityFrameRepository: AvailabilityFrameRepository;
  readonly subscriptionRepository: SubscriptionRepository;
  readonly supportRequestRepository: SupportRequestRepository;
  readonly availabilityFrameRead: AvailabilityFrameReadPort;
  readonly reachabilityRead: ReachabilityReadPort;
  readonly readRights: AccountReadRightsPort;
  readonly choreographyStore: ChoreographyStorePort;
  readonly settlement: SettlementAclPort;
  readonly clock: Clock;
  readonly commandJournal: SequenceJournalPort;
  readonly readJournal: ReadJournalPort;
  readonly reactionJournal: ReactionJournalPort;
  /** The DECLARED actor the choreography commands with (a system emitter in the closed list — M-10). */
  readonly choreographyActor: ActorRef;
  readonly environment: string;
  readonly product: {
    readonly reachability: ReachabilityPolicyParams;
    readonly subscription: SubscriptionPolicyParams;
  };
  readonly technical?: {
    readonly commandMaxAttempts?: number;
  };
}

export interface AccountAssembly {
  readonly commandDispatch: CommandDispatch;
  readonly queryDispatch: QueryDispatch;
  readonly reactionDispatch: ReactionDispatch;
  readonly services: {
    readonly registerPerson: RegisterPersonApplicationService;
    readonly changePreference: ChangePreferenceApplicationService;
    readonly changeReachability: ChangeReachabilityApplicationService;
    readonly registerDevice: RegisterDeviceApplicationService;
    readonly removeDevice: RemoveDeviceApplicationService;
    readonly closeAccount: CloseAccountApplicationService;
    readonly changeAvailabilityFrame: ChangeAvailabilityFrameApplicationService;
    readonly startSubscription: StartSubscriptionApplicationService;
    readonly endSubscription: EndSubscriptionApplicationService;
    readonly openSupportRequest: OpenSupportRequestApplicationService;
    readonly handleSupportRequest: HandleSupportRequestApplicationService;
    readonly availabilityFrameQuery: AvailabilityFrameQueryApplicationService;
    readonly reachabilityQuery: ReachabilityQueryApplicationService;
  };
  readonly policies: { readonly reachability: ReachabilityPolicy; readonly subscription: SubscriptionPolicy };
  readonly settlement: { readonly adapterName: string; readonly provisional: boolean };
  /**
   * The DECLARED handler of the Outbox de commandes (I-12: "c'est un handler
   * déclaré qui commande"): drains the choreography's emitted commands into
   * the CommandDispatch with the declared actor. Returns the outcomes.
   */
  readonly drainChoreography: () => Promise<readonly SequenceOutcome<unknown, SequenceRefusalLike>[]>;
  readonly machinery: { readonly clock: Clock; readonly commandJournal: SequenceJournalPort };
}

export const composeAccount = (providers: AccountCompositionProviders): AccountAssembly => {
  // ---- the Policies with their PRODUCT parameters (RFC-003 P5).
  const reachability = new ReachabilityPolicy(providers.product.reachability);
  const subscription = new SubscriptionPolicy(providers.product.subscription);

  const machinery: AccountSequenceMachinery = {
    clock: providers.clock,
    journal: providers.commandJournal,
    ...(providers.technical?.commandMaxAttempts !== undefined
      ? { maxAttempts: providers.technical.commandMaxAttempts }
      : {}),
  };

  // ---- the ELEVEN carriers + the TWO readers.
  const services = {
    registerPerson: new RegisterPersonApplicationService({ repository: providers.accountRepository }, machinery),
    changePreference: new ChangePreferenceApplicationService({ repository: providers.accountRepository }, machinery),
    changeReachability: new ChangeReachabilityApplicationService(
      { repository: providers.accountRepository, reachability },
      machinery,
    ),
    registerDevice: new RegisterDeviceApplicationService({ repository: providers.accountRepository }, machinery),
    removeDevice: new RemoveDeviceApplicationService({ repository: providers.accountRepository }, machinery),
    closeAccount: new CloseAccountApplicationService({ repository: providers.accountRepository }, machinery),
    changeAvailabilityFrame: new ChangeAvailabilityFrameApplicationService(
      { repository: providers.availabilityFrameRepository },
      machinery,
    ),
    startSubscription: new StartSubscriptionApplicationService(
      { repository: providers.subscriptionRepository, subscription },
      machinery,
    ),
    endSubscription: new EndSubscriptionApplicationService({ repository: providers.subscriptionRepository }, machinery),
    openSupportRequest: new OpenSupportRequestApplicationService(
      { repository: providers.supportRequestRepository },
      machinery,
    ),
    handleSupportRequest: new HandleSupportRequestApplicationService(
      { repository: providers.supportRequestRepository },
      machinery,
    ),
    availabilityFrameQuery: new AvailabilityFrameQueryApplicationService(
      { readPort: providers.availabilityFrameRead },
      { journal: providers.readJournal },
    ),
    reachabilityQuery: new ReachabilityQueryApplicationService(
      { readPort: providers.reachabilityRead, rightsPort: providers.readRights },
      { journal: providers.readJournal },
    ),
  } as const;

  // ---- the Account ACL toward the Settlement: the Subscription is the
  // Commissioner — the ORDER is commissioned AFTER the retention of
  // SubscriptionStarted (A-4: nothing is ordered that was not retained),
  // by this DECLARED post-retention act of the composition, never by the
  // carrier itself (it stays boring) nor by an adapter (I-12). The ACL's
  // own violation is reported in the outcome's place: never hidden.
  const startAndCommission = async (input: SequenceInput): Promise<SequenceOutcome<Subscription, SequenceRefusalLike>> => {
    const outcome = await services.startSubscription.execute(input);
    if (outcome.kind === 'executed') {
      const wire = input.payload as StartSubscriptionWire;
      const commissioned = await providers.settlement.commission({
        subscriptionId: wire.subscriptionId,
        commissioner: wire.personId,
        offerReference: wire.offerReference,
      });
      if (!commissioned.ok) {
        return {
          kind: 'abandoned',
          failure: { kind: 'Failure', code: commissioned.error.code, message: commissioned.error.message, retryable: true },
          attempts: outcome.attempts,
        };
      }
    }
    return outcome;
  };

  // ---- the Dispatchers AND THEIR TABLES — closed, declared here.
  const commandCarriers: readonly CommandCarrier[] = [
    { commandType: 'RegisterPerson', execute: (input) => services.registerPerson.execute(input) },
    { commandType: 'ChangePreference', execute: (input) => services.changePreference.execute(input) },
    { commandType: 'ChangeReachability', execute: (input) => services.changeReachability.execute(input) },
    { commandType: 'RegisterDevice', execute: (input) => services.registerDevice.execute(input) },
    { commandType: 'RemoveDevice', execute: (input) => services.removeDevice.execute(input) },
    { commandType: 'CloseAccount', execute: (input) => services.closeAccount.execute(input) },
    { commandType: 'ChangeAvailabilityFrame', execute: (input) => services.changeAvailabilityFrame.execute(input) },
    { commandType: 'StartSubscription', execute: startAndCommission },
    { commandType: 'EndSubscription', execute: (input) => services.endSubscription.execute(input) },
    { commandType: 'OpenSupportRequest', execute: (input) => services.openSupportRequest.execute(input) },
    { commandType: 'HandleSupportRequest', execute: (input) => services.handleSupportRequest.execute(input) },
  ];
  const commandDispatch = new CommandDispatch(commandCarriers);
  const queryDispatch = accountQueryDispatch(services.availabilityFrameQuery, services.reachabilityQuery);
  const reactionDispatch = accountReactionDispatch(providers.choreographyStore, {
    clock: providers.clock,
    journal: providers.reactionJournal,
    ...(providers.technical?.commandMaxAttempts !== undefined
      ? { maxAttempts: providers.technical.commandMaxAttempts }
      : {}),
  });

  const drainChoreography = async (): Promise<readonly SequenceOutcome<unknown, SequenceRefusalLike>[]> => {
    const pending = await providers.choreographyStore.pendingCommands();
    const outcomes: SequenceOutcome<unknown, SequenceRefusalLike>[] = [];
    for (const { key, command } of pending) {
      outcomes.push(
        await commandDispatch.dispatch({
          payload: command,
          actor: providers.choreographyActor,
          correlationId: command.commandId as unknown as CorrelationId,
        }),
      );
      await providers.choreographyStore.markCarried([key]);
    }
    return outcomes;
  };

  // ---- BOOT VALIDATION, fail closed (F4.4 §7).
  const carried = new Set(commandDispatch.commandTypes);
  for (const commandType of ACCOUNT_COMMAND_TYPES) {
    invariant(carried.has(commandType), `ratified Command '${commandType}' has no carrier — pas de démarrage (F4.4 §7)`);
  }
  invariant(
    carried.size === ACCOUNT_COMMAND_TYPES.length,
    'the command table carries something outside the ratified catalogue 36-46 — pas de démarrage',
  );
  invariant(
    queryDispatch.queryTypes.length === ACCOUNT_QUERY_TYPES.length &&
      ACCOUNT_QUERY_TYPES.every((type) => queryDispatch.queryTypes.includes(type)),
    'the query table must serve exactly the TWO ratified Account lectures (F3.3 §5)',
  );
  invariant(
    reactionDispatch.factTypes.length === CHOREOGRAPHY_FACT_TYPES.length,
    'the reaction table must be exactly the declared choreography (RFC-003 P3/P4)',
  );
  const provisional = providers.settlement.adapterName === DEVELOPMENT_NO_SETTLEMENT;
  invariant(
    !provisional || providers.environment === 'development',
    `the Settlement ACL adapter is PROVISIONAL (${DEVELOPMENT_NO_SETTLEMENT}) and may not exist in '${providers.environment}' — pas de démarrage`,
  );

  return {
    commandDispatch,
    queryDispatch,
    reactionDispatch,
    services,
    policies: { reachability, subscription },
    settlement: { adapterName: providers.settlement.adapterName, provisional },
    drainChoreography,
    machinery: { clock: providers.clock, commandJournal: providers.commandJournal },
  };
};
