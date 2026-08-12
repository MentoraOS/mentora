import type { Clock, IdGenerator } from '@mentora/kernel';
import type { Config, Logger } from '@mentora/shared';

import type { Token } from './token.js';
import { createToken } from './token.js';

/**
 * The DI tokens for the platform's universal ports. An app binds each token to a
 * concrete adapter at its composition root; every other package depends on the
 * token (a name), never on the implementation.
 */

export const CLOCK: Token<Clock> = createToken<Clock>('mentora.kernel.Clock');
export const ID_GENERATOR: Token<IdGenerator> = createToken<IdGenerator>('mentora.kernel.IdGenerator');
export const LOGGER: Token<Logger> = createToken<Logger>('mentora.shared.Logger');
export const CONFIG: Token<Config> = createToken<Config>('mentora.shared.Config');
