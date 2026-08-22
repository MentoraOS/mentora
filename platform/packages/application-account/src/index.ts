/**
 * @mentora/application-account — the Account application layer (Lot A03):
 * one generic Séquence plug, eleven boring carriers (36-46), the two
 * ratified lectures (n°4, n°10), the declared choreography (RFC-003
 * P3/P4), the Settlement ACL port with its PROVISIONAL development
 * adapter, and composeAccount boot-validated against the catalogues.
 */

export * from './definitions/account-sequence-definition.js';
export * from './factories/account-command-factory.js';
export * from './services/account-application-services.js';
export * from './read/ports/account-read.port.js';
export * from './read/errors/account-read-refusal.js';
export * from './read/definitions/account-query-definitions.js';
export * from './read/services/account-query-services.js';
export * from './read/testing/account-read-doubles.js';
export * from './reactions/account-choreography.js';
export * from './acl/settlement-acl.port.js';
export * from './acl/development-no-settlement-adapter.js';
export * from './composition/account-composition.js';
