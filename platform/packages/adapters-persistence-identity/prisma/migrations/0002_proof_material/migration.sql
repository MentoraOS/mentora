-- 0002_proof_material — EXPAND (S-7): the dev-vault table of proof material
-- (Story #96, "hash sous coffre"). Additive only; reversible by window.
-- The digest is one-way (scrypt): nothing here can be read back as matter.
CREATE TABLE "ProofMaterial" (
    "factorId" TEXT NOT NULL,
    "kind"     TEXT NOT NULL,
    "digest"   TEXT NOT NULL,

    CONSTRAINT "ProofMaterial_pkey" PRIMARY KEY ("factorId")
);
