/**
 * @mentora/testing-clock — deterministic time for tests.
 *
 * `FakeClock` implements the kernel `Clock` port with a manually-advanced
 * instant, and `VirtualScheduler` runs delayed callbacks in virtual time — no
 * real waiting, ever. Tests that use these are deterministic by construction
 * (the code form of F4.1 A-6: time is injected, never ambient).
 */

export { FakeClock } from './fake-clock.js';
export { VirtualScheduler } from './virtual-scheduler.js';
export type { ScheduledTask } from './virtual-scheduler.js';
