-- 0001_init — the Agreement registry (Canonical Persistence Model, RC-1).
-- Hand-authored expand migration (S-7: expand-contract; executed by the
-- Migration species, never by an Application boot).

CREATE TABLE "AgreementSnapshot" (
    "agreementId" TEXT NOT NULL,
    "version"     INTEGER NOT NULL,
    "payload"     TEXT NOT NULL,
    "checksum"    TEXT NOT NULL,
    "expertId"    TEXT NOT NULL,
    "slotStartMs" BIGINT NOT NULL,
    "slotEndMs"   BIGINT NOT NULL,
    "stateKind"   TEXT NOT NULL,

    CONSTRAINT "AgreementSnapshot_pkey" PRIMARY KEY ("agreementId")
);

CREATE INDEX "AgreementSnapshot_expertId_stateKind_idx"
    ON "AgreementSnapshot"("expertId", "stateKind");

CREATE TABLE "AgreementFact" (
    "agreementId"     TEXT NOT NULL,
    "sequence"        INTEGER NOT NULL,
    "type"            TEXT NOT NULL,
    "payload"         TEXT NOT NULL,
    "contractVersion" INTEGER NOT NULL,
    "occurredAtMs"    BIGINT NOT NULL,
    "checksum"        TEXT NOT NULL,

    CONSTRAINT "AgreementFact_pkey" PRIMARY KEY ("agreementId", "sequence")
);

CREATE TABLE "AgreementOutbox" (
    "id"               BIGSERIAL NOT NULL,
    "messageId"        TEXT NOT NULL,
    "agreementId"      TEXT NOT NULL,
    "sequence"         INTEGER NOT NULL,
    "correlationId"    TEXT,
    "causationId"      TEXT,
    "deliveryAttempts" INTEGER NOT NULL DEFAULT 0,
    "payload"          TEXT NOT NULL,
    "occurredAtMs"     BIGINT NOT NULL,
    "status"           TEXT NOT NULL DEFAULT 'pending',

    CONSTRAINT "AgreementOutbox_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "AgreementOutbox_messageId_key" ON "AgreementOutbox"("messageId");
CREATE UNIQUE INDEX "AgreementOutbox_agreementId_sequence_key"
    ON "AgreementOutbox"("agreementId", "sequence");
CREATE INDEX "AgreementOutbox_status_id_idx" ON "AgreementOutbox"("status", "id");

CREATE TABLE "AgreementInbox" (
    "consumer"      TEXT NOT NULL,
    "agreementId"   TEXT NOT NULL,
    "sequence"      INTEGER NOT NULL,
    "processedAtMs" BIGINT NOT NULL,

    CONSTRAINT "AgreementInbox_pkey" PRIMARY KEY ("consumer", "agreementId", "sequence")
);

-- The declared R-A key, applied STRUCTURALLY by the registry (F3.2-A, R-A):
-- one expert never holds two CONFIRMED agreements on overlapping slots. The
-- rule lives in the domain (OverlappingSlotSpecification); this constraint
-- is its declared key; the violation is refused as the motivated Decision
-- TimeSlotUnavailable — never an exception, never a lock (F5.1 §19).
CREATE EXTENSION IF NOT EXISTS btree_gist;

ALTER TABLE "AgreementSnapshot"
    ADD CONSTRAINT "agreement_confirmed_slot_ra_key"
    EXCLUDE USING gist (
        "expertId" WITH =,
        int8range("slotStartMs", "slotEndMs") WITH &&
    )
    WHERE ("stateKind" = 'Confirmed');
