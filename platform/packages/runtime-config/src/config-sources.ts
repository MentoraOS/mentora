/**
 * Configuration SOURCES — free mechanisms (the canon legislates the three
 * species and the boot validation, never the source; F4.4 §5). THE ONE RULE
 * THIS PACKAGE ENFORCES BY EXISTING: `process.env` is read HERE and nowhere
 * else in the workspace — ambient environment is a vestibule concern.
 */

export interface ConfigSource {
  readonly name: string;
  read(key: string): string | undefined;
}

/** The process environment — the only lawful reading of process.env. */
export const environmentSource = (): ConfigSource => ({
  name: 'environment',
  read: (key) => process.env[key],
});

/** A literal in-memory source (tests, defaults-of-last-resort at the Root). */
export const inMemorySource = (
  name: string,
  entries: Readonly<Record<string, string>>,
): ConfigSource => ({
  name,
  read: (key) => entries[key],
});
