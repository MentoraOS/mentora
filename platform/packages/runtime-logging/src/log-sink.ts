/**
 * Where formatted lines go — free mechanisms (the emission is neutral and
 * ours, the wells interchangeable — O-10). File rotation is an abstraction
 * only here (LogRotationStrategy): actual file handling is an adapter's
 * resource under I-11, not this package's.
 */

export interface LogSink {
  write(line: string): void;
}

 
export const consoleSink: LogSink = {
  write: (line) => {
    console.log(line);
  },
};
 

/** In-memory sink — tests and boot-time buffering. */
export class MemoryLogSink implements LogSink {
  readonly lines: string[] = [];

  write(line: string): void {
    this.lines.push(line);
  }
}

/**
 * Rotation, ABSTRACT ONLY: the decision "should this well rotate" — never
 * named a Policy (the Policy block is the published product rule of F3.1;
 * rotation is pure technique, I-5).
 */
export interface LogRotationStrategy {
  shouldRotate(currentSizeBytes: number, ageMillis: number): boolean;
}
