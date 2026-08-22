/**
 * @mentora/domain-account — the Account domain (canon F3.2-B, domaine 6).
 * Lot A01: the Account unit (the person's truth — its identity IS the
 * PersonId, RFC-003 P1) and the AvailabilityFrame unit (born at its first
 * change, RFC-003 P2), their ports, memory references and contract suites
 * (on subpaths). Pure business truth: no framework, no I/O, no clock.
 */

export * from './ids/identifiers.js';
export * from './errors/account-exceptions.js';
export * from './value-objects/preference.js';
export * from './value-objects/reachability-channel.js';
export * from './value-objects/verification-state.js';
export * from './value-objects/account-state.js';
export * from './value-objects/availability-window.js';
export * from './entities/device.js';
export * from './commands/account-commands.js';
export * from './events/account-events.js';
export * from './decisions/account-refusal.js';
export * from './snapshots/account-snapshot.js';
export * from './aggregate/account-domain-event.js';
export * from './aggregate/account.js';
export * from './aggregate/availability-frame.js';
export * from './factories/account-factory.js';
export * from './specifications/closable-account.specification.js';
export * from './specifications/coherent-frame.specification.js';
export * from './policies/reachability.policy.js';
export * from './ports/account-repository.js';
export * from './testing/in-memory-account-repository.js';
