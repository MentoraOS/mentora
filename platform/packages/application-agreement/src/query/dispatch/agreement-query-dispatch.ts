import { QueryDispatch } from '@mentora/application-kernel';

import type { AgreementStateQueryApplicationService } from '../services/agreement-state-query.application-service.js';

/**
 * The Agreement entries of the Query Dispatch (F4.1 §6): the table is CLOSED
 * and declared — today it holds the ONE ratified Agreement read. "UN Query →
 * UN lecteur → UNE réponse"; a duplicate carrier refuses at assembly (fail
 * closed). The dispatch routes; R-C and the journal are executed by the
 * reader's own Séquence de Lecture (pas 3 and 6).
 */
export const agreementQueryDispatch = (
  stateReader: AgreementStateQueryApplicationService,
): QueryDispatch => new QueryDispatch([stateReader]);
