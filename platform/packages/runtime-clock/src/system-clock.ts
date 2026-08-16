import type { Clock, Instant } from '@mentora/kernel';
import { instantOf } from '@mentora/kernel';

/**
 * SystemClock — the ONE lawful reading of the machine clock. A-6: "identité,
 * temps, corrélation : injectés, jamais ambiants — un instant par exécution";
 * "horloge lue" is an absolute interdiction inside the rings (F4.1). The
 * ambient read lives HERE, below the Root, and nowhere else: the Root builds
 * this Clock and INJECTS it into every Séquence (F4.4 §2).
 */
export class SystemClock implements Clock {
  now(): Instant {
    return instantOf(Date.now());
  }
}
