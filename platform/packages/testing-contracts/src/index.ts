/**
 * @mentora/testing-contracts — contract tests for ports.
 *
 * A port (an interface) makes promises; every implementation must keep them.
 * A contract suite states those promises ONCE as executable tests and runs
 * them against each implementation — the fake in tests and the real adapter in
 * integration both prove the same behavior (F4.4 I-10: "le réel ne se teste
 * qu'aux contrats d'Adapters").
 */

export { verifyShape, describeContract } from './contract.js';
export type { ContractCase, ContractSuite, ShapeSpec } from './contract.js';
export { clockContract } from './suites/clock-contract.js';
export { idGeneratorContract } from './suites/id-generator-contract.js';
