import type * as Wire from '@mentora/contracts-account';
import type {
  ChangeAvailabilityFrame,
  ChangePreference,
  ChangeReachability,
  CloseAccount,
  EndSubscription,
  HandleSupportRequest,
  OpenSupportRequest,
  RegisterDevice,
  RegisterPerson,
  RemoveDevice,
  StartSubscription,
} from '@mentora/domain-account';
import {
  commandIdOf,
  deviceIdOf,
  personIdOf,
  preferenceKindOf,
  preferenceValueOf,
  reachabilityChannelOf,
  subscriptionIdOf,
  supportRequestIdOf,
  verificationStateOf,
} from '@mentora/domain-account';
import type { Instant } from '@mentora/kernel';
import { instantOf } from '@mentora/kernel';

/**
 * The wire→domain seams of the eleven commands (pas 5): the published wire
 * + the injected instant → the typed domain command. Blanks were refused at
 * reception; the domain guards remain the Exception door for malformed
 * internal calls. A PreferenceKind outside the three ratified VOs is ALSO a
 * caller defect (the guard throws) — never a Refusal.
 */

export const toRegisterPerson = (wire: Wire.RegisterPerson, instant: Instant): RegisterPerson => ({
  commandId: commandIdOf(wire.commandId),
  personId: personIdOf(wire.personId),
  verificationState: verificationStateOf(wire.verificationState),
  registeredAt: instant,
});

export const toChangePreference = (wire: Wire.ChangePreference, instant: Instant): ChangePreference => ({
  commandId: commandIdOf(wire.commandId),
  personId: personIdOf(wire.personId),
  preference: {
    kind: preferenceKindOf(wire.preference.kind),
    value: preferenceValueOf(wire.preference.value),
  },
  changedAt: instant,
});

export const toChangeReachability = (
  wire: Wire.ChangeReachability,
  instant: Instant,
): ChangeReachability => ({
  commandId: commandIdOf(wire.commandId),
  personId: personIdOf(wire.personId),
  channel: reachabilityChannelOf(wire.channel),
  changedAt: instant,
});

export const toRegisterDevice = (wire: Wire.RegisterDevice, instant: Instant): RegisterDevice => ({
  commandId: commandIdOf(wire.commandId),
  personId: personIdOf(wire.personId),
  deviceId: deviceIdOf(wire.deviceId),
  registeredAt: instant,
});

export const toRemoveDevice = (wire: Wire.RemoveDevice, instant: Instant): RemoveDevice => ({
  commandId: commandIdOf(wire.commandId),
  personId: personIdOf(wire.personId),
  deviceId: deviceIdOf(wire.deviceId),
  removedAt: instant,
});

export const toCloseAccount = (wire: Wire.CloseAccount, instant: Instant): CloseAccount => ({
  commandId: commandIdOf(wire.commandId),
  personId: personIdOf(wire.personId),
  motive: wire.motive,
  closedAt: instant,
});

export const toChangeAvailabilityFrame = (
  wire: Wire.ChangeAvailabilityFrame,
  instant: Instant,
): ChangeAvailabilityFrame => ({
  commandId: commandIdOf(wire.commandId),
  personId: personIdOf(wire.personId),
  windows: wire.windows.map((window) => ({
    start: instantOf(window.startMs),
    end: instantOf(window.endMs),
  })),
  changedAt: instant,
});

export const toStartSubscription = (
  wire: Wire.StartSubscription,
  instant: Instant,
): StartSubscription => ({
  commandId: commandIdOf(wire.commandId),
  subscriptionId: subscriptionIdOf(wire.subscriptionId),
  personId: personIdOf(wire.personId),
  offerReference: wire.offerReference,
  startedAt: instant,
});

export const toEndSubscription = (wire: Wire.EndSubscription, instant: Instant): EndSubscription => ({
  commandId: commandIdOf(wire.commandId),
  subscriptionId: subscriptionIdOf(wire.subscriptionId),
  motive: wire.motive,
  endedAt: instant,
});

export const toOpenSupportRequest = (
  wire: Wire.OpenSupportRequest,
  instant: Instant,
): OpenSupportRequest => ({
  commandId: commandIdOf(wire.commandId),
  supportRequestId: supportRequestIdOf(wire.supportRequestId),
  requesterId: personIdOf(wire.personId),
  motive: wire.motive,
  openedAt: instant,
});

export const toHandleSupportRequest = (
  wire: Wire.HandleSupportRequest,
  instant: Instant,
): HandleSupportRequest => ({
  commandId: commandIdOf(wire.commandId),
  supportRequestId: supportRequestIdOf(wire.supportRequestId),
  handledAt: instant,
});
