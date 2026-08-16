import type { ActorRef, CorrelationId } from '@mentora/contracts';
import { describe, expect, it } from 'vitest';

import { CommandDispatch } from './dispatch/command-dispatch.js';
import type { CommandCarrier } from './dispatch/command-dispatch.js';

/**
 * The Command Dispatcher's frozen properties (F4.1 §6): closed readable
 * table, ONE carrier per Command (duplicate = assembly error), the act
 * identity demanded before routing, zero thinking (A-8).
 */

const ACTOR = 'actor-1' as ActorRef;
const CORRELATION = 'corr-cd-1' as CorrelationId;

const carrierOf = (commandType: string): CommandCarrier & { calls: number } => {
  const carrier = {
    commandType,
    calls: 0,
    execute: () => {
      carrier.calls += 1;
      return Promise.resolve({ kind: 'executed', unit: commandType, attempts: 1 } as const);
    },
  };
  return carrier;
};

const input = (payload: unknown) => ({ payload, actor: ACTOR, correlationId: CORRELATION });

describe('CommandDispatch (F4.1 §6)', () => {
  it('routes a Command to its ONE carrier and returns its outcome', async () => {
    const probe = carrierOf('ProbeCommand');
    const dispatch = new CommandDispatch([probe, carrierOf('OtherCommand')]);
    const outcome = await dispatch.dispatch(input({ type: 'ProbeCommand', commandId: 'c1' }));
    expect(outcome.kind).toBe('executed');
    expect(probe.calls).toBe(1);
    expect(dispatch.commandTypes).toEqual(['ProbeCommand', 'OtherCommand']);
  });

  it('two carriers for the same Command refuse at assembly — the startup error', () => {
    expect(
      () => new CommandDispatch([carrierOf('ProbeCommand'), carrierOf('ProbeCommand')]),
    ).toThrow();
  });

  it('demands the act identity: a missing or blank commandId never routes (F4.1 §3)', async () => {
    const probe = carrierOf('ProbeCommand');
    const dispatch = new CommandDispatch([probe]);
    const missing = await dispatch.dispatch(input({ type: 'ProbeCommand' }));
    const blank = await dispatch.dispatch(input({ type: 'ProbeCommand', commandId: '  ' }));
    expect(missing.kind).toBe('exception');
    expect(blank.kind).toBe('exception');
    expect(probe.calls).toBe(0);
  });

  it('an unknown Command and a non-object payload are Exception values', async () => {
    const dispatch = new CommandDispatch([carrierOf('ProbeCommand')]);
    expect((await dispatch.dispatch(input({ type: 'Nobody', commandId: 'c1' }))).kind).toBe(
      'exception',
    );
    expect((await dispatch.dispatch(input('not-an-object'))).kind).toBe('exception');
  });
});
