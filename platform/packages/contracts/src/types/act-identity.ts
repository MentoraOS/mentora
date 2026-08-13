import type { Brand } from '@mentora/kernel';

/**
 * CommandId — the ratified ACT IDENTITY (F4.1 §3: replay of the SAME act
 * identity is deduplicated; a deliberate retry is a NEW act). Transversal:
 * every domain's commands carry one. Lives in the technical core so no domain
 * redeclares it (no-duplication law).
 */
export type CommandId = Brand<string, 'CommandId'>;
