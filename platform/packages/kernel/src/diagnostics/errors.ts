/**
 * The kernel error taxonomy.
 *
 * A `KernelError` is a *programmer* error — a broken invariant, a guard that
 * should never have failed. It is thrown. This is distinct from a *domain*
 * refusal, which is a value (a `Result`/`Decision`), never an exception — the
 * Foundation's F3.1.14 distinction between an Exception (a malformed call) and a
 * Refusal (a legitimate, motivated NO). The kernel provides the former; the
 * latter is expressed with `Result`.
 */

/** Base class for every error the platform throws deliberately. */
export abstract class KernelError extends Error {
  /** A stable, machine-readable discriminant, e.g. `KERNEL.INVARIANT_VIOLATION`. */
  abstract readonly code: string;

  constructor(message: string, options?: { readonly cause?: unknown }) {
    super(message, options);
    // Restore the prototype chain (necessary when targeting ES generally, and
    // harmless otherwise) and give the instance a useful name.
    this.name = new.target.name;
    Object.setPrototypeOf(this, new.target.prototype);
  }
}

/** Thrown when an invariant that must always hold does not. */
export class InvariantViolationError extends KernelError {
  readonly code = 'KERNEL.INVARIANT_VIOLATION';
}

/** Thrown by a guard when a value fails a precondition (e.g. required-but-absent). */
export class GuardError extends KernelError {
  readonly code = 'KERNEL.GUARD';
}
