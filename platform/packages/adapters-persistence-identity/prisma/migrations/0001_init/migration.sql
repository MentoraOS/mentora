-- 0001_init — the Identity & Access registries (Canonical Persistence
-- Model, RC-1). Hand-authored expand migration (S-7: expand-contract;
-- executed by the Migration species, never by an Application boot).
--
-- TWO registries, ONE deliberate asymmetry: the Credential circulates its
-- two ratified facts (stream + outbox + inbox); the Session is STATE ONLY —
-- no fact table, no outbox, no inbox EXISTS for it. The absence is the law
-- ("aucun fait publié"), not an omission.

CREATE TABLE "CredentialSnapshot" (
    "credentialId"        TEXT NOT NULL,
    "version"             INTEGER NOT NULL,
    "payload"             TEXT NOT NULL,
    "checksum"            TEXT NOT NULL,
    "personId"            TEXT NOT NULL,
    "principalFactorKind" TEXT NOT NULL,
    "stateKind"           TEXT NOT NULL,

    CONSTRAINT "CredentialSnapshot_pkey" PRIMARY KEY ("credentialId")
);

CREATE INDEX "CredentialSnapshot_personId_stateKind_idx"
    ON "CredentialSnapshot"("personId", "stateKind");

CREATE TABLE "CredentialFact" (
    "credentialId"    TEXT NOT NULL,
    "sequence"        INTEGER NOT NULL,
    "type"            TEXT NOT NULL,
    "payload"         TEXT NOT NULL,
    "contractVersion" INTEGER NOT NULL,
    "occurredAtMs"    BIGINT NOT NULL,
    "checksum"        TEXT NOT NULL,

    CONSTRAINT "CredentialFact_pkey" PRIMARY KEY ("credentialId", "sequence")
);

CREATE TABLE "CredentialOutbox" (
    "id"               BIGSERIAL NOT NULL,
    "messageId"        TEXT NOT NULL,
    "credentialId"     TEXT NOT NULL,
    "sequence"         INTEGER NOT NULL,
    "correlationId"    TEXT,
    "causationId"      TEXT,
    "deliveryAttempts" INTEGER NOT NULL DEFAULT 0,
    "payload"          TEXT NOT NULL,
    "occurredAtMs"     BIGINT NOT NULL,
    "status"           TEXT NOT NULL DEFAULT 'pending',
    "claimedUntilMs"   BIGINT NOT NULL DEFAULT 0,
    "nextAttemptAtMs"  BIGINT NOT NULL DEFAULT 0,
    "quarantineReason" TEXT,

    CONSTRAINT "CredentialOutbox_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "CredentialOutbox_messageId_key" ON "CredentialOutbox"("messageId");
CREATE UNIQUE INDEX "CredentialOutbox_credentialId_sequence_key"
    ON "CredentialOutbox"("credentialId", "sequence");
CREATE INDEX "CredentialOutbox_status_id_idx" ON "CredentialOutbox"("status", "id");

CREATE TABLE "CredentialInbox" (
    "consumer"      TEXT NOT NULL,
    "credentialId"  TEXT NOT NULL,
    "sequence"      INTEGER NOT NULL,
    "processedAtMs" BIGINT NOT NULL,

    CONSTRAINT "CredentialInbox_pkey" PRIMARY KEY ("consumer", "credentialId", "sequence")
);

CREATE TABLE "SessionSnapshot" (
    "sessionId"    TEXT NOT NULL,
    "version"      INTEGER NOT NULL,
    "payload"      TEXT NOT NULL,
    "checksum"     TEXT NOT NULL,
    "credentialId" TEXT NOT NULL,
    "stateKind"    TEXT NOT NULL,

    CONSTRAINT "SessionSnapshot_pkey" PRIMARY KEY ("sessionId")
);

CREATE INDEX "SessionSnapshot_credentialId_stateKind_idx"
    ON "SessionSnapshot"("credentialId", "stateKind");

-- The declared R-A key, applied STRUCTURALLY by the registry (F3.2-A, R-A):
-- one person never holds two ACTIVE credentials on the same principal-factor
-- kind. The rule lives in the domain (ActiveCredentialUniquenessSpecification);
-- this partial unique index is its declared key; the violation is refused as
-- the motivated Decision CredentialAlreadyExists (the settled dictionary
-- name, `<Truth>AlreadyExists` family) — never an exception, never a lock
-- (F5.1 §19).
CREATE UNIQUE INDEX "credential_active_principal_ra_key"
    ON "CredentialSnapshot"("personId", "principalFactorKind")
    WHERE "stateKind" = 'Active';
