/**
 * @mentora/domain-identity — the Identity & Access domain. Story #10 ships
 * the Credential unit (the proof of entry, never the person); the Session
 * unit arrives with Story #29. Pure business truth: no framework, no I/O,
 * no clock, and NO SECRET MATERIAL EVER — by construction.
 */

export * from './ids/identifiers.js';
export * from './errors/identity-exceptions.js';
export * from './value-objects/factor-kind.js';
export * from './value-objects/proof-strength.js';
export * from './value-objects/credential-state.js';
export * from './entities/factor.js';
export * from './commands/credential-commands.js';
export * from './events/credential-events.js';
export * from './decisions/credential-refusal.js';
export * from './snapshots/credential-snapshot.js';
export * from './aggregate/credential-domain-event.js';
export * from './aggregate/credential.js';
export * from './factories/credential-factory.js';
export * from './ports/credential-repository.js';
export * from './specifications/active-credential-uniqueness.specification.js';
export * from './testing/in-memory-credential-repository.js';
export * from './value-objects/session-state.js';
export * from './commands/session-commands.js';
export * from './decisions/session-refusal.js';
export * from './policies/proof-requirement.policy.js';
export * from './snapshots/session-snapshot.js';
export * from './aggregate/session.js';
export * from './factories/session-factory.js';
export * from './ports/session-repository.js';
export * from './testing/in-memory-session-repository.js';
