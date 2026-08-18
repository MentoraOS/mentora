import type { Result } from '@mentora/kernel';
import { ok } from '@mentora/kernel';

import { Session } from '../aggregate/session.js';
import type { OpenSession } from '../commands/session-commands.js';
import type { SessionRefusal } from '../decisions/session-refusal.js';
import type { ProofRequirementPolicy } from '../policies/proof-requirement.policy.js';

/**
 * The birth door of the Session (F3.1): opened ON A PROOF — the injected
 * ProofRequirementPolicy judges the presented strength BEFORE anything is
 * born; an insufficient proof is a motivated Refusal (`ProofUnavailable`,
 * the ratified family), never an error. The credential's EXISTENCE and
 * ACTIVITY are the application layer's loading concern; the strength is
 * data on the command (the mechanism verified the material outside).
 */
export const openSession = (
  command: OpenSession,
  policy: ProofRequirementPolicy,
): Result<Session, SessionRefusal> => {
  const judged = policy.judge(command.presentedStrength);
  if (!judged.ok) {
    return judged;
  }
  return ok(Session._born(command.sessionId, command.credentialId, command.openedAt));
};
