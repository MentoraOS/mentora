import type {
  SequenceDefinition,
  SequenceInput,
  SequenceJournalPort,
  SequenceOutcome,
  SequenceRefusalLike,
} from '@mentora/application-kernel';
import { SequenceBuilder, type SequenceExecutor } from '@mentora/application-kernel';
import type * as Wire from '@mentora/contracts-account';
import type {
  Account,
  AccountRefusal,
  AccountRepository,
  AvailabilityFrame,
  AvailabilityFrameRefusal,
  AvailabilityFrameRepository,
  ReachabilityPolicy,
  Subscription,
  SubscriptionPolicy,
  SubscriptionRefusal,
  SubscriptionRepository,
  SupportRequest,
  SupportRequestRefusal,
  SupportRequestRepository,
} from '@mentora/domain-account';
import {
  accountRefusal,
  changeAvailabilityFrameBirth,
  openSupportRequest,
  personIdOf,
  registerPerson,
  startSubscription,
  subscriptionIdOf,
  subscriptionRefusal,
  supportRequestIdOf,
  supportRequestRefusal,
} from '@mentora/domain-account';
import type { Clock, Instant, Result } from '@mentora/kernel';
import { err, ok } from '@mentora/kernel';

import type { AccountRegistrySeams, AccountUseCase } from '../definitions/account-sequence-definition.js';
import {
  absentRefusal,
  accountSequenceDefinition,
  inhabitedRefusal,
} from '../definitions/account-sequence-definition.js';
import * as seam from '../factories/account-command-factory.js';

/** The machinery the composition root injects (I-2) — the reference shape. */
export interface AccountSequenceMachinery {
  readonly clock: Clock;
  readonly journal: SequenceJournalPort;
  readonly maxAttempts?: number;
}

/**
 * The eleven BORING carriers (A-1: one Command, one carrier; F4.1 §7: "il ne
 * décide pas"): each builds its Séquence from the ONE generic plug and
 * delegates. Births refuse an inhabited Identifier (R-B); transitions
 * refuse absence; everything else is the unit's Decision.
 */
abstract class AccountSequenceApplicationService<
  TWire extends Wire.AccountCommandContract,
  TCommand,
  TUnit,
  TRefusal extends SequenceRefusalLike,
> {
  private readonly executor: SequenceExecutor<TWire, TCommand, TUnit, TRefusal>;

  protected constructor(
    definition: SequenceDefinition<TWire, TCommand, TUnit, TRefusal>,
    machinery: AccountSequenceMachinery,
  ) {
    const builder = new SequenceBuilder<TWire, TCommand, TUnit, TRefusal>()
      .withDefinition(definition)
      .withClock(machinery.clock)
      .withJournal(machinery.journal);
    this.executor = (
      machinery.maxAttempts === undefined ? builder : builder.withMaxAttempts(machinery.maxAttempts)
    ).build();
  }

  execute(input: SequenceInput): Promise<SequenceOutcome<TUnit, TRefusal>> {
    return this.executor.execute(input);
  }
}

// ------------------------------------------------------------ Account (36-41)

const accountSeams = <TWire extends Wire.AccountCommandContract>(
  repository: AccountRepository,
): AccountRegistrySeams<TWire, Account, AccountRefusal> => ({
  load: (wire) => repository.byId(personIdOf(wire.personId)),
  retain: (unit, context) => repository.retain(unit, context),
});

export class RegisterPersonApplicationService extends AccountSequenceApplicationService<
  Wire.RegisterPerson,
  ReturnType<typeof seam.toRegisterPerson>,
  Account,
  AccountRefusal
> {
  constructor(deps: { readonly repository: AccountRepository }, machinery: AccountSequenceMachinery) {
    const useCase: AccountUseCase<Wire.RegisterPerson, ReturnType<typeof seam.toRegisterPerson>, Account, AccountRefusal> = {
      commandType: 'RegisterPerson',
      map: (wire, instant) => ok(seam.toRegisterPerson(wire, instant)),
      act: (unit, command) =>
        unit.some ? err(inhabitedRefusal(accountRefusal, 'Account')) : registerPerson(command),
    };
    super(accountSequenceDefinition(useCase, accountSeams(deps.repository)), machinery);
  }
}

/** A transition use case on a LIVING account: absence refuses, the unit decides. */
const accountTransition = <TWire extends Wire.AccountCommandContract, TCommand>(
  commandType: TWire['type'],
  map: (wire: TWire, instant: Instant) => TCommand,
  act: (account: Account, command: TCommand) => Result<Account, AccountRefusal>,
): AccountUseCase<TWire, TCommand, Account, AccountRefusal> => ({
  commandType,
  map: (wire, instant) => ok(map(wire, instant)),
  act: (unit, command) =>
    unit.some ? act(unit.value, command) : err(absentRefusal(accountRefusal, 'Account')),
});

export class ChangePreferenceApplicationService extends AccountSequenceApplicationService<
  Wire.ChangePreference,
  ReturnType<typeof seam.toChangePreference>,
  Account,
  AccountRefusal
> {
  constructor(deps: { readonly repository: AccountRepository }, machinery: AccountSequenceMachinery) {
    super(
      accountSequenceDefinition(
        accountTransition('ChangePreference', seam.toChangePreference, (account, command) =>
          account.changePreference(command),
        ),
        accountSeams(deps.repository),
      ),
      machinery,
    );
  }
}

export class ChangeReachabilityApplicationService extends AccountSequenceApplicationService<
  Wire.ChangeReachability,
  ReturnType<typeof seam.toChangeReachability>,
  Account,
  AccountRefusal
> {
  constructor(
    deps: { readonly repository: AccountRepository; readonly reachability: ReachabilityPolicy },
    machinery: AccountSequenceMachinery,
  ) {
    // The RATIFIED policy judges the channel at the seam (pas 5: a source
    // validity, loi 15) BEFORE the unit acts — same split as OpenSession.
    const useCase: AccountUseCase<Wire.ChangeReachability, ReturnType<typeof seam.toChangeReachability>, Account, AccountRefusal> = {
      commandType: 'ChangeReachability',
      map: (wire, instant) => {
        const command = seam.toChangeReachability(wire, instant);
        const judged = deps.reachability.judge(command.channel);
        return judged.ok ? ok(command) : judged;
      },
      act: (unit, command) =>
        unit.some ? unit.value.changeReachability(command) : err(absentRefusal(accountRefusal, 'Account')),
    };
    super(accountSequenceDefinition(useCase, accountSeams(deps.repository)), machinery);
  }
}

export class RegisterDeviceApplicationService extends AccountSequenceApplicationService<
  Wire.RegisterDevice,
  ReturnType<typeof seam.toRegisterDevice>,
  Account,
  AccountRefusal
> {
  constructor(deps: { readonly repository: AccountRepository }, machinery: AccountSequenceMachinery) {
    super(
      accountSequenceDefinition(
        accountTransition('RegisterDevice', seam.toRegisterDevice, (account, command) =>
          account.registerDevice(command),
        ),
        accountSeams(deps.repository),
      ),
      machinery,
    );
  }
}

export class RemoveDeviceApplicationService extends AccountSequenceApplicationService<
  Wire.RemoveDevice,
  ReturnType<typeof seam.toRemoveDevice>,
  Account,
  AccountRefusal
> {
  constructor(deps: { readonly repository: AccountRepository }, machinery: AccountSequenceMachinery) {
    super(
      accountSequenceDefinition(
        accountTransition('RemoveDevice', seam.toRemoveDevice, (account, command) =>
          account.removeDevice(command),
        ),
        accountSeams(deps.repository),
      ),
      machinery,
    );
  }
}

export class CloseAccountApplicationService extends AccountSequenceApplicationService<
  Wire.CloseAccount,
  ReturnType<typeof seam.toCloseAccount>,
  Account,
  AccountRefusal
> {
  constructor(deps: { readonly repository: AccountRepository }, machinery: AccountSequenceMachinery) {
    super(
      accountSequenceDefinition(
        accountTransition('CloseAccount', seam.toCloseAccount, (account, command) => account.close(command)),
        accountSeams(deps.repository),
      ),
      machinery,
    );
  }
}

// ---------------------------------------------------- AvailabilityFrame (42)

/** 42 — RFC-003 P2: absent ⇒ birth (the first change), present ⇒ change. ONE carrier, two doors. */
export class ChangeAvailabilityFrameApplicationService extends AccountSequenceApplicationService<
  Wire.ChangeAvailabilityFrame,
  ReturnType<typeof seam.toChangeAvailabilityFrame>,
  AvailabilityFrame,
  AvailabilityFrameRefusal
> {
  constructor(
    deps: { readonly repository: AvailabilityFrameRepository },
    machinery: AccountSequenceMachinery,
  ) {
    const useCase: AccountUseCase<
      Wire.ChangeAvailabilityFrame,
      ReturnType<typeof seam.toChangeAvailabilityFrame>,
      AvailabilityFrame,
      AvailabilityFrameRefusal
    > = {
      commandType: 'ChangeAvailabilityFrame',
      map: (wire, instant) => ok(seam.toChangeAvailabilityFrame(wire, instant)),
      act: (unit, command) =>
        unit.some ? unit.value.change(command) : changeAvailabilityFrameBirth(command),
    };
    super(
      accountSequenceDefinition(useCase, {
        load: (wire) => deps.repository.byId(personIdOf(wire.personId)),
        retain: deps.repository.retain.bind(deps.repository),
      }),
      machinery,
    );
  }
}

// --------------------------------------------------------- Subscription (43-44)

export class StartSubscriptionApplicationService extends AccountSequenceApplicationService<
  Wire.StartSubscription,
  ReturnType<typeof seam.toStartSubscription>,
  Subscription,
  SubscriptionRefusal
> {
  constructor(
    deps: { readonly repository: SubscriptionRepository; readonly subscription: SubscriptionPolicy },
    machinery: AccountSequenceMachinery,
  ) {
    const useCase: AccountUseCase<Wire.StartSubscription, ReturnType<typeof seam.toStartSubscription>, Subscription, SubscriptionRefusal> = {
      commandType: 'StartSubscription',
      map: (wire, instant) => ok(seam.toStartSubscription(wire, instant)),
      act: (unit, command) =>
        unit.some
          ? err(inhabitedRefusal(subscriptionRefusal, 'Subscription'))
          : startSubscription(command, deps.subscription),
    };
    super(
      accountSequenceDefinition(useCase, {
        load: (wire) => deps.repository.byId(subscriptionIdOf(wire.subscriptionId)),
        retain: deps.repository.retain.bind(deps.repository),
      }),
      machinery,
    );
  }
}

export class EndSubscriptionApplicationService extends AccountSequenceApplicationService<
  Wire.EndSubscription,
  ReturnType<typeof seam.toEndSubscription>,
  Subscription,
  SubscriptionRefusal
> {
  constructor(deps: { readonly repository: SubscriptionRepository }, machinery: AccountSequenceMachinery) {
    const useCase: AccountUseCase<Wire.EndSubscription, ReturnType<typeof seam.toEndSubscription>, Subscription, SubscriptionRefusal> = {
      commandType: 'EndSubscription',
      map: (wire, instant) => ok(seam.toEndSubscription(wire, instant)),
      act: (unit, command) =>
        unit.some ? unit.value.end(command) : err(absentRefusal(subscriptionRefusal, 'Subscription')),
    };
    super(
      accountSequenceDefinition(useCase, {
        load: (wire) => deps.repository.byId(subscriptionIdOf(wire.subscriptionId)),
        retain: deps.repository.retain.bind(deps.repository),
      }),
      machinery,
    );
  }
}

// ------------------------------------------------------ SupportRequest (45-46)

export class OpenSupportRequestApplicationService extends AccountSequenceApplicationService<
  Wire.OpenSupportRequest,
  ReturnType<typeof seam.toOpenSupportRequest>,
  SupportRequest,
  SupportRequestRefusal
> {
  constructor(deps: { readonly repository: SupportRequestRepository }, machinery: AccountSequenceMachinery) {
    const useCase: AccountUseCase<Wire.OpenSupportRequest, ReturnType<typeof seam.toOpenSupportRequest>, SupportRequest, SupportRequestRefusal> = {
      commandType: 'OpenSupportRequest',
      map: (wire, instant) => ok(seam.toOpenSupportRequest(wire, instant)),
      act: (unit, command) =>
        unit.some ? err(inhabitedRefusal(supportRequestRefusal, 'SupportRequest')) : openSupportRequest(command),
    };
    super(
      accountSequenceDefinition(useCase, {
        load: (wire) => deps.repository.byId(supportRequestIdOf(wire.supportRequestId)),
        retain: deps.repository.retain.bind(deps.repository),
      }),
      machinery,
    );
  }
}

export class HandleSupportRequestApplicationService extends AccountSequenceApplicationService<
  Wire.HandleSupportRequest,
  ReturnType<typeof seam.toHandleSupportRequest>,
  SupportRequest,
  SupportRequestRefusal
> {
  constructor(deps: { readonly repository: SupportRequestRepository }, machinery: AccountSequenceMachinery) {
    const useCase: AccountUseCase<Wire.HandleSupportRequest, ReturnType<typeof seam.toHandleSupportRequest>, SupportRequest, SupportRequestRefusal> = {
      commandType: 'HandleSupportRequest',
      map: (wire, instant) => ok(seam.toHandleSupportRequest(wire, instant)),
      act: (unit, command) =>
        unit.some ? unit.value.handle(command) : err(absentRefusal(supportRequestRefusal, 'SupportRequest')),
    };
    super(
      accountSequenceDefinition(useCase, {
        load: (wire) => deps.repository.byId(supportRequestIdOf(wire.supportRequestId)),
        retain: deps.repository.retain.bind(deps.repository),
      }),
      machinery,
    );
  }
}

