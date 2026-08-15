/**
 * Pas 1 of the Lecture — Reception: the SINGLE definition already lives in
 * the 1C-1 reception module (which delegates entirely to the published
 * language, @mentora/contracts-agreement). Re-exported here so the query
 * side has its reception where the architecture expects it, with ONE
 * definition (anti-duplication — the same law as the 1C-2 re-exports).
 */

export { receiveAgreementQuery } from '../../validators/reception.js';
