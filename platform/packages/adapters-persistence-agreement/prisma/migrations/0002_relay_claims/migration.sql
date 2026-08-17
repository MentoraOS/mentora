-- 0002_relay_claims — EXPAND (S-7): the relay's claim bookkeeping on the
-- Outbox de faits. Additive only: existing rows keep working (defaults);
-- reversible by window (drop the three columns). Announced by Lot 2B-2.
ALTER TABLE "AgreementOutbox" ADD COLUMN "claimedUntilMs" BIGINT NOT NULL DEFAULT 0;
ALTER TABLE "AgreementOutbox" ADD COLUMN "nextAttemptAtMs" BIGINT NOT NULL DEFAULT 0;
ALTER TABLE "AgreementOutbox" ADD COLUMN "quarantineReason" TEXT;
