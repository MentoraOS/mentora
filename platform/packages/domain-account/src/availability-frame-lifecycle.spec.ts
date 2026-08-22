import { instantOf } from '@mentora/kernel';
import { describe, expect, it } from 'vitest';

import { AvailabilityFrame } from './aggregate/availability-frame.js';
import { changeAvailabilityFrameBirth } from './factories/account-factory.js';
import { CoherentFrameSpecification } from './specifications/coherent-frame.specification.js';
import { changeOf } from './testing/availability-frame-repository-contract-suite.js';

describe('AvailabilityFrame — alive, born at its first change, coherent or refused', () => {
  const coherent = new CoherentFrameSpecification();

  it('the first change IS the birth: version 1, the ONE ratified fact, identity = the person', () => {
    const born = changeAvailabilityFrameBirth(changeOf('person-1', [[1_000, 2_000], [3_000, 4_000]]));
    expect(born.ok).toBe(true);
    if (!born.ok) return;
    expect(born.value.id).toBe('person-1');
    expect(born.value.version).toBe(1);
    expect(born.value.unretainedActs).toBe(1);
    expect(born.value.pendingFacts.map((fact) => fact.type)).toEqual(['AvailabilityFrameChanged']);
  });

  it('CoherentFrameSpecification: well-formed and non-overlapping; touching windows are coherent; empty is coherent', () => {
    const windows = (pairs: readonly [number, number][]) =>
      pairs.map(([start, end]) => ({ start: instantOf(start), end: instantOf(end) }));
    expect(coherent.isSatisfiedBy(windows([]))).toBe(true);
    expect(coherent.isSatisfiedBy(windows([[1, 2], [2, 3]]))).toBe(true);
    expect(coherent.isSatisfiedBy(windows([[3, 4], [1, 2]]))).toBe(true);
    expect(coherent.isSatisfiedBy(windows([[2, 2]]))).toBe(false);
    expect(coherent.isSatisfiedBy(windows([[3, 1]]))).toBe(false);
    expect(coherent.isSatisfiedBy(windows([[1, 3], [2, 4]]))).toBe(false);
  });

  it('an incoherent set refuses at birth AND at change — WindowUnavailable, a motivated VALUE', () => {
    const birth = changeAvailabilityFrameBirth(changeOf('person-1', [[5, 1]]));
    expect(!birth.ok && birth.error.reason).toBe('WindowUnavailable');
    const frame = changeAvailabilityFrameBirth(changeOf('person-1', [[1, 2]]));
    if (!frame.ok) throw new Error('unreachable');
    const change = frame.value.change(changeOf('person-1', [[1, 3], [2, 4]], 2_000));
    expect(!change.ok && change.error.reason).toBe('WindowUnavailable');
  });

  it('a change replaces the whole frame: version +1, one more fact; retained() empties', () => {
    const frame = changeAvailabilityFrameBirth(changeOf('person-1', [[1, 2]]));
    if (!frame.ok) throw new Error('unreachable');
    const changed = frame.value.change(changeOf('person-1', [[10, 20]], 2_000));
    if (!changed.ok) throw new Error('unreachable');
    expect(changed.value.windows.map((window) => window.start.epochMillis)).toEqual([10]);
    expect(changed.value.version).toBe(2);
    expect(changed.value.pendingFacts).toHaveLength(2);
    const retained = changed.value.retained();
    expect(retained.pendingFacts).toHaveLength(0);
    expect(retained.unretainedActs).toBe(0);
    expect(retained.version).toBe(2);
  });

  it('snapshot round-trips; an incoherent or version-0 photograph is corruption', () => {
    const frame = changeAvailabilityFrameBirth(changeOf('person-1', [[1, 2], [3, 4]]));
    if (!frame.ok) throw new Error('unreachable');
    const back = AvailabilityFrame.fromSnapshot(frame.value.snapshot());
    expect(back.snapshot()).toEqual(frame.value.snapshot());
    expect(() => AvailabilityFrame.fromSnapshot({ ...frame.value.snapshot(), version: 0 })).toThrow(/incoherent|version/);
    expect(() =>
      AvailabilityFrame.fromSnapshot({ personId: 'person-1', windows: [{ startMs: 5, endMs: 1 }], version: 1 }),
    ).toThrow(/incoherent/);
  });

  it('key surface: no clock, no person data, no content — only what the canon names', () => {
    const frame = changeAvailabilityFrameBirth(changeOf('person-1', [[1, 2]]));
    if (!frame.ok) throw new Error('unreachable');
    expect(Object.keys(frame.value).sort()).toEqual(['id', 'pendingFacts', 'unretainedActs', 'version', 'windows']);
  });
});
