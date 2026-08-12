/**
 * @mentora/testing — core test helpers.
 *
 * Custom matchers for the kernel's functional types, a typed fixture builder,
 * a seeded random-data factory, and golden-file helpers. No business logic.
 */

export { mentoraMatchers, registerMentoraMatchers } from './matchers.js';
export { defineFixture, buildMany } from './fixtures.js';
export type { FixtureFactory } from './fixtures.js';
export { RandomFactory } from './random.js';
export { toStableJson, compareToGoldenFile } from './golden.js';
export type { GoldenComparison } from './golden.js';
