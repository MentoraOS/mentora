import type { CommandEnvelope, EventEnvelope, QueryEnvelope } from '@mentora/contracts';

import type { AgreementCommandContract } from '../commands/agreement-command-contracts.js';
import type { AgreementStateQuery } from '../queries/agreement-state.query.js';
import type { AgreementEventContract } from '../wire/event-union.js';

/**
 * Agreement-typed instantiations of the CORE envelopes (@mentora/contracts —
 * the single definition; M-3 is transversal law, so the envelope shape is
 * mutualized and only INSTANTIATED here). Correlation/causation/attempts ride
 * these, never the facts (F4.1 §9, M-3).
 */

export type AgreementCommandEnvelope = CommandEnvelope<AgreementCommandContract>;
export type AgreementEventEnvelope = EventEnvelope<AgreementEventContract>;
export type AgreementQueryEnvelope = QueryEnvelope<AgreementStateQuery>;
