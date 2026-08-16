/**
 * @mentora/runtime-config — technical configuration loading and fail-closed
 * validation (I-5; F4.4 §7: "chaque configuration est du bon type et dans
 * ses bornes … Une seule erreur = pas de démarrage"). The ONLY package that
 * reads process.env. Product parameters ride here only as validated DATA on
 * their way to the Root's Policy construction; secrets only as NAMES.
 */

export * from './config-schema.js';
export * from './config-sources.js';
export * from './load-config.js';
