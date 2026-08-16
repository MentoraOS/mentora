/**
 * @mentora/runtime-clock — the runtime implementations of the kernel Clock
 * port (the port stays owned by its consumers — F4.4 §3/I-4; these are the
 * mechanisms below). The ONE vestibule where the machine clock is read (A-6).
 */

export * from './system-clock.js';
export * from './monotonic-clock.js';
export * from './clock-factory.js';
