import type { ReadDefinition } from '@mentora/application-kernel';
import type {
  AvailabilityFrameQuery,
  AvailabilityFrameResponse,
  ReachabilityQuery,
  ReachabilityResponse,
} from '@mentora/contracts-account';
import { validateAccountQuery } from '@mentora/contracts-account';
import type { Result } from '@mentora/kernel';
import { err, ok } from '@mentora/kernel';

import type { AccountReadRefusal } from '../errors/account-read-refusal.js';
import { accountReadRefusal } from '../errors/account-read-refusal.js';
import type {
  AccountReadRightsPort,
  AvailabilityFrameReadPort,
  AvailabilityFrameView,
  ReachabilityReadPort,
  ReachabilityView,
} from '../ports/account-read.port.js';

/**
 * The TWO ratified Account lectures plugged into the Séquence de Lecture
 * (precedent: agreementStateQueryDefinition). No other Account read exists
 * (F3.3 §5): no profile, no search, no browse.
 */

const receiveAs =
  <TQuery extends AvailabilityFrameQuery | ReachabilityQuery>(type: TQuery['type']) =>
  (payload: unknown): Result<TQuery, readonly { code: string; field: string; message: string }[]> => {
    const received = validateAccountQuery(payload);
    if (!received.ok) {
      return received;
    }
    if (received.value.type !== type) {
      return err([
        { code: 'CONTRACT.UNKNOWN_CONTRACT', field: 'type', message: `This reader carries '${type}'` },
      ]);
    }
    return ok(received.value as TQuery);
  };

/** n°4 — "ayant droit : tous (cadre publié)": the grid admits every injected identity. */
export const availabilityFrameQueryDefinition = (deps: {
  readonly readPort: AvailabilityFrameReadPort;
}): ReadDefinition<AvailabilityFrameQuery, AvailabilityFrameView, AvailabilityFrameResponse, AccountReadRefusal> => ({
  queryTypeOf: (wire) => wire.type,
  receive: receiveAs<AvailabilityFrameQuery>('AvailabilityFrameQuery'),
  // Pas 3 — the declared grid is "tous": every actor holds the right.
  entitled: () => Promise.resolve(ok(undefined)),
  read: (query) => deps.readPort.frameOf(query.personId),
  absent: () =>
    accountReadRefusal(
      'AccountUnavailable',
      'No published frame lives under this person — motivated, never silence (F2.6)',
    ),
  // Pas 5 — the windows ⊘ everything else of the Account.
  respond: (view) => ({
    contractVersion: 1,
    type: 'AvailabilityFrameResponse',
    personId: view.personId,
    windows: view.windows,
    version: view.version,
  }),
});

/** n°10 — "la Notification (sanctionnée) + le Titulaire". */
export const reachabilityQueryDefinition = (deps: {
  readonly readPort: ReachabilityReadPort;
  readonly rightsPort: AccountReadRightsPort;
}): ReadDefinition<ReachabilityQuery, ReachabilityView, ReachabilityResponse, AccountReadRefusal> => ({
  queryTypeOf: (wire) => wire.type,
  receive: receiveAs<ReachabilityQuery>('ReachabilityQuery'),
  entitled: async (query, actor) => {
    const held = await deps.rightsPort.holdsReachabilityRight(actor, query.personId);
    return held
      ? ok(undefined)
      : err(
          accountReadRefusal(
            'RightMissing',
            'The declared grid grants this read to the sanctioned Notification and the holder only (F3.3 §5)',
          ),
        );
  },
  read: (query) => deps.readPort.reachabilityOf(query.personId),
  absent: () =>
    accountReadRefusal(
      'AccountUnavailable',
      'No account lives under this person — motivated, never silence (F2.6)',
    ),
  // Pas 5 — the channel ⊘ preferences, devices, life: the domain never exits.
  respond: (view) => ({
    contractVersion: 1,
    type: 'ReachabilityResponse',
    personId: view.personId,
    ...(view.channel === undefined ? {} : { channel: view.channel }),
  }),
});
