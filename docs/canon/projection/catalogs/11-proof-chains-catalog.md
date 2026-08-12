---
doc: canon-catalog-11-proof-chains
title: Catalogue des chaînes de preuve, vestibules & identités de confiance
type: projection
titre: canon
statut: "Projeté — R2-Projections Lot 4 (Catalogues)"
corpus_ref: "foundation-v1.0.0 (8d095ee)"
proprietaire: Conseil Constitutionnel de Mentora
projete_par: "R2-Projections Lot 4"
source_autorite:
  - "F5.4 — Security (cinq chaînes de preuve, deux vestibules, Trust Model) — source/production/04-security.md"
  - "F5.4.99 — Chaîne de Révocation (6e chaîne) — source/production/04-security.md"
  - "F5.99 Procès IV — la Chaîne de Démonstration unique — source/production/09-grand-audit.md"
note: >-
  INDEX des chaînes de preuve, vestibules et identités de confiance. Projection
  déterministe de la Source. Chaque entrée : nom · gardien · référence. Aucun
  contenu. La confiance est démontrée à chaque traversée (T-2), jamais héritée.
  Évolution : Titre VII.
---

# Catalogue des chaînes de preuve

**But.** Retrouver toute chaîne de preuve, tout vestibule, toute identité de
confiance. **Portée.** Les six chaînes, les deux vestibules et le Trust Model
(F5.4). **Index seul.** *La confiance est un théorème démontré à chaque
traversée* ([T-2](../../source/production/04-security.md)).

## A. Les six chaînes de preuve (F5.4)

| # | Chaîne | Gardien | Source |
|---|--------|---------|--------|
| 1 | Personnes — `Credential` → `Session` → `ActorRef` injecté | I&A / propriétaire de l'acte | [F5.4 P1](../../source/production/04-security.md) |
| 2 | Artefacts — source → fabrication → `ArtifactId` signé → Boot prouvé | Build | [F5.4 P1](../../source/production/04-security.md) |
| 3 | Machines — artefact prouvé → Preuve de machine → traversées mTLS | vestibule des machines | [F5.4 P1](../../source/production/04-security.md) |
| 4 | Faits — provenances, constatants, polices (F3) | gardien du registre | [F5.4 P1](../../source/production/04-security.md) |
| 5 | Exécution — Correlation/Causation dans les Enveloppes (F4) | Application | [F5.4 P1](../../source/production/04-security.md) |
| 6 | Révocation — toute preuve morte se démontre (`Struck`/`Invalidated`/`Readmitted`, `Withdrawn`, révocation I&A) | propriétaire de l'objet révoqué | [F5.4.99](../../source/production/04-security.md) |

## B. Les deux vestibules (jamais mêlés)

| Vestibule | Objet | Source |
|-----------|-------|--------|
| Vestibule des personnes | `Credential`, `Session` (gelés) | [F5.4 P1, T-4](../../source/production/04-security.md) |
| Vestibule des machines | Preuves de machine (source → artefact → boot prouvé) | [F5.4 P1, T-4](../../source/production/04-security.md) |

## C. Identités de confiance & Trust Model

| Élément | Rôle | Source |
|---------|------|--------|
| Trust Model | table de jonction des chaînes, déclarée et boot-vérifiée | [F5.4 P1, T-5](../../source/production/04-security.md) |
| Secret Zero (Cérémonie de Fondation) | la première confiance, injectée sous témoins | [F5.4 P3, T-20](../../source/production/04-security.md) |
| chaîne d'approvisionnement | Source → Build → Artifact → Signature → SBOM → Attestation → Boot → Preuve de machine → Runtime | [F5.4 P3, T-21](../../source/production/04-security.md) |
| identités de gouvernance de sécurité | `SecurityPolicyId`, `ThreatModelId`, `RiskId`, `ControlId`, `VulnerabilityId`, `SecurityReviewId`, `DisclosureId` | [F5.4.99](../../source/production/04-security.md) |

## Références

[F5.4](../../source/production/04-security.md) · [F5.4.99](../../source/production/04-security.md) · [F5.99 Procès IV](../../source/production/09-grand-audit.md) (la Chaîne de Démonstration unique) · [Catalogue des identités](07-identities-catalog.md).

## Notes

- Le Grand Audit (Procès IV) démontre que les six chaînes sont **six visages d'une seule Chaîne de Démonstration** : toute entité a origine, propagation, terminaison et reconstruction ([F5.99](../../source/production/09-grand-audit.md)). Le Trust Model est **boot-vérifié** (fail closed) ; aucune confiance n'est héritée d'une position (T-2).
