import type { Instant } from '@mentora/kernel';

import type { DeviceId } from '../ids/identifiers.js';

/**
 * Device — an Entity of the Account ("même acteur, aucune référence entrante :
 * I&A référence SES Credential, jamais le Device" — canon F3.2-B). RFC-003
 * P7 (ratified): identity + instant and NOTHING else — a label, a platform,
 * a fingerprint are surface data, never a truth of the domain until the
 * dictionary names them. Registering/removing a device publishes NO fact.
 */
export interface Device {
  readonly deviceId: DeviceId;
  readonly registeredAt: Instant;
}
