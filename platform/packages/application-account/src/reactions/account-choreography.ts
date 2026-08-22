import type {
  ReactionCarrier,
  ReactionDefinition,
  ReactionInput,
  ReactionJournalPort,
  ReactionOutcome,
  ReactionResult,
} from '@mentora/application-kernel';
import { ReactionBuilder, ReactionDispatch } from '@mentora/application-kernel';
import type { AccountEventContract, EndSubscription } from '@mentora/contracts-account';
import { validateAccountEvent } from '@mentora/contracts-account';
import type { Clock, Instant, Option } from '@mentora/kernel';
import { none, ok, some } from '@mentora/kernel';

import type { SettlementReport } from '../acl/settlement-acl.port.js';

/**
 * The DECLARED internal choreography of the Account (canon F3.2-B: "la
 * fermeture se propage aux unités sœurs par le fait AccountClosed —
 * chorégraphie interne"; RFC-003 P3 + P4, ratified): ONE journey per
 * person whose only memory is its POSITION — the holder's active
 * subscription, learned from SubscriptionStarted. It reacts to:
 *   - AccountClosed            → EndSubscription(active one)   [P3]
 *   - SettlementReport failed  → EndSubscription(that one)     [P4]
 * SubscriptionEnded is NOT consumed: its ratified wire names no person, so
 * no journey key can be derived from it without evolving the contract
 * (forbidden this lot). Consequence, accepted and idempotent: the position
 * may still name a subscription the holder already ended — the emitted
 * EndSubscription is then REFUSED by the unit (TransitionUnavailable) at
 * the carrier; the unit decides, the journey never does. The position is
 * cleared whenever the journey emits.
 * It never decides (the Subscription's machine does, at the carrier), never
 * publishes, never talks to another journey (P-10). The emitted commands
 * go to the Outbox de commandes (the store seam); a DECLARED handler at the
 * composition carries them to the CommandDispatch (I-12: an adapter never
 * commands by itself).
 *
 * The P4 fact is NOT a Settlement wire: it is the ACL's REPORT, in Account's
 * words (M-7) — carried in the same journey as a consumed input.
 */

export interface ChoreographyPosition {
  readonly activeSubscriptionId?: string;
}

/** The consumed inputs: the person-keyed published facts and the ACL's report. */
export type ChoreographyInput =
  | Extract<AccountEventContract, { readonly personId: unknown }>
  | { readonly type: 'SettlementReport'; readonly personId: string; readonly report: SettlementReport };

export type ChoreographyCommand = EndSubscription;

/** The journey's store — Inbox, position and Outbox de commandes behind ONE seam (owned here, I-4). */
export interface ChoreographyStorePort {
  seen(factIdentity: string): Promise<boolean>;
  positionOf(journeyKey: string): Promise<Option<ChoreographyPosition>>;
  retain(
    factIdentity: string,
    journeyKey: string,
    result: ReactionResult<ChoreographyPosition, ChoreographyCommand>,
  ): Promise<void>;
  /** The Outbox de commandes — drained by the declared handler. */
  pendingCommands(): Promise<readonly { readonly key: string; readonly command: ChoreographyCommand }[]>;
  markCarried(keys: readonly string[]): Promise<void>;
}

const endCommand = (subscriptionId: string, personId: string, motive: string, instant: Instant): EndSubscription => ({
  contractVersion: 1,
  type: 'EndSubscription',
  commandId: `choreography:${subscriptionId}:${motive}:${String(instant.epochMillis)}` as EndSubscription['commandId'],
  personId: personId as EndSubscription['personId'],
  subscriptionId: subscriptionId as EndSubscription['subscriptionId'],
  motive,
});

export const accountChoreographyDefinition = (
  store: ChoreographyStorePort,
): ReactionDefinition<ChoreographyInput, ChoreographyPosition, ChoreographyCommand> => ({
  factTypeOf: (fact) => fact.type,
  factIdentityOf: (fact) =>
    fact.type === 'SettlementReport'
      ? `settlement:${fact.report.subscriptionId}:${fact.report.kind}`
      : `${fact.type}:${fact.type === 'SubscriptionStarted' ? fact.subscriptionId : fact.personId}:${String(fact.sequence)}`,
  journeyKeyOf: (fact) => fact.personId,

  receive: (payload) => {
    if (
      typeof payload === 'object' &&
      payload !== null &&
      (payload as Record<string, unknown>)['type'] === 'SettlementReport'
    ) {
      const record = payload as { personId?: unknown; report?: unknown };
      const report = record.report as SettlementReport | undefined;
      if (typeof record.personId !== 'string' || report === undefined || typeof report.subscriptionId !== 'string') {
        return { ok: false, error: [{ code: 'CONTRACT.MALFORMED', field: 'report', message: 'a report names its person and subscription' }] };
      }
      return ok(payload as ChoreographyInput);
    }
    const validated = validateAccountEvent(payload);
    if (!validated.ok) {
      return validated;
    }
    if (!('personId' in validated.value)) {
      return { ok: false, error: [{ code: 'CONTRACT.UNKNOWN_CONTRACT', field: 'type', message: 'the choreography consumes person-keyed facts only' }] };
    }
    return ok(validated.value);
  },

  seen: (factIdentity) => store.seen(factIdentity),
  positionOf: (journeyKey) => store.positionOf(journeyKey),

  react: (position, fact, instant) => {
    const current = position.some ? position.value : {};
    switch (fact.type) {
      case 'SubscriptionStarted':
        return { position: { activeSubscriptionId: fact.subscriptionId }, commands: [] };
      case 'AccountClosed':
        return current.activeSubscriptionId === undefined
          ? { position: current, commands: [] }
          : {
              position: {},
              commands: [endCommand(current.activeSubscriptionId, fact.personId, 'account-closed', instant)],
            };
      case 'SettlementReport':
        return fact.report.kind === 'failed' && current.activeSubscriptionId === fact.report.subscriptionId
          ? { position: {}, commands: [endCommand(fact.report.subscriptionId, fact.personId, 'settlement-failed', instant)] }
          : { position: current, commands: [] };
      case 'PersonRegistered':
      case 'PreferenceChanged':
      case 'ReachabilityChanged':
      case 'AvailabilityFrameChanged':
        // Person-keyed facts the journey receives but does not react to.
        return { position: current, commands: [] };
    }
  },

  retain: (factIdentity, journeyKey, result) => store.retain(factIdentity, journeyKey, result),
});

/** The declared fact types this dispatch consumes — the CLOSED subscription table. */
export const CHOREOGRAPHY_FACT_TYPES = [
  'SubscriptionStarted',
  'AccountClosed',
  'SettlementReport',
] as const;

export const accountReactionDispatch = (
  store: ChoreographyStorePort,
  machinery: { readonly clock: Clock; readonly journal: ReactionJournalPort; readonly maxAttempts?: number },
): ReactionDispatch => {
  const builder = new ReactionBuilder<ChoreographyInput, ChoreographyPosition, ChoreographyCommand>()
    .withDefinition(accountChoreographyDefinition(store))
    .withClock(machinery.clock)
    .withJournal(machinery.journal);
  const executor = (
    machinery.maxAttempts === undefined ? builder : builder.withMaxAttempts(machinery.maxAttempts)
  ).build();
  const carriers: readonly ReactionCarrier[] = CHOREOGRAPHY_FACT_TYPES.map((factType) => ({
    factType,
    execute: (input: ReactionInput): Promise<ReactionOutcome<unknown, unknown>> => executor.execute(input),
  }));
  return new ReactionDispatch(carriers);
};

/** In-memory reference of the journey store (I-10) — the PostgreSQL store arrives with A04. */
export class InMemoryChoreographyStore implements ChoreographyStorePort {
  private readonly inbox = new Set<string>();
  private readonly positions = new Map<string, ChoreographyPosition>();
  private readonly outbox = new Map<string, ChoreographyCommand>();
  private sequence = 0;

  seen(factIdentity: string): Promise<boolean> {
    return Promise.resolve(this.inbox.has(factIdentity));
  }

  positionOf(journeyKey: string): Promise<Option<ChoreographyPosition>> {
    const position = this.positions.get(journeyKey);
    return Promise.resolve(position === undefined ? none : some(position));
  }

  retain(
    factIdentity: string,
    journeyKey: string,
    result: ReactionResult<ChoreographyPosition, ChoreographyCommand>,
  ): Promise<void> {
    this.inbox.add(factIdentity);
    this.positions.set(journeyKey, result.position);
    for (const command of result.commands) {
      this.sequence += 1;
      this.outbox.set(`${String(this.sequence)}:${command.commandId}`, command);
    }
    return Promise.resolve();
  }

  pendingCommands(): Promise<readonly { readonly key: string; readonly command: ChoreographyCommand }[]> {
    return Promise.resolve([...this.outbox.entries()].map(([key, command]) => ({ key, command })));
  }

  markCarried(keys: readonly string[]): Promise<void> {
    for (const key of keys) {
      this.outbox.delete(key);
    }
    return Promise.resolve();
  }
}
