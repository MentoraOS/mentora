---
doc: canon-catalog-07-identities
title: Catalogue des identités
type: projection
titre: canon
statut: "Projeté — R2-Projections Lot 4 (Catalogues)"
corpus_ref: "foundation-v1.0.0 (8d095ee)"
proprietaire: Conseil Constitutionnel de Mentora
projete_par: "R2-Projections Lot 4"
source_autorite:
  - "F3.1.99 §Identité — l'Identifier (opaque, stable, jamais recyclé) — source/domain/01-tactical-building-blocks.md"
  - "F5.1→F5.8 — identités de la Production — source/production/01..08"
  - "F5.99 — Théorème des identités & identités refusées (Procès V) — source/production/09-grand-audit.md"
note: >-
  INDEX des familles d'identités. Projection déterministe de la Source. Chaque
  entrée : identité · chapitre propriétaire · objet identifié (définition terse) ·
  référence. Reçoit une identité exactement ce qui est un objet gouverné à cycle de
  vie (Théorème des identités, F5.99). Aucun contenu. Évolution : Titre VII.
---

# Catalogue des identités

**But.** Retrouver toute famille d'identités et son objet. **Portée.** Les
identités du domaine (F3) et de la Production (F5). **Index seul.** Loi :
l'`Identifier` est opaque, stable, jamais recyclé, jamais dérivé d'une donnée
mutable ([F3.1.99 §4](../../source/domain/01-tactical-building-blocks.md)) ;
**Théorème des identités** — objet gouverné à cycle de vie → identité ; tout le
reste → pas d'identité ([F5.99](../../source/production/09-grand-audit.md)).

## A. Identités du domaine (F3)

Chaque agrégat porte son `Identifier` (`<Truth>Id`). Les 30 sont au
[Catalogue des agrégats](05-aggregates-catalog.md). Cas notables :

| Identité | Objet | Source |
|----------|-------|--------|
| `<Truth>Id` (× 30) | l'unité de vérité (un par agrégat) | [F3.2-A/B/C](../../source/domain/02-aggregates-customer-journey.md) |
| identité singleton-par-acteur (`FundsLedger` = `ExpertId`, `ConsentLedger` = Accordant) | référence-comme-identité (seule exception écrite) | [F3.2-B.99 / F3.2-C](../../source/domain/03-aggregates-identity-collaboration.md) |
| identités d'Entities (`Favorite`, `PayoutRecord`, `Message`, `ConsentGrant`…) | identités intérieures à une racine | [F3.2-A/B/C](../../source/domain/02-aggregates-customer-journey.md) |

## B. Identités de la Production (F5)

| Chapitre | Identités | Objet | Source |
|----------|-----------|-------|--------|
| Runtime | `ExecutableId`, `ArtifactId`, `InstanceId`, `FleetId` | mission / artefact / occurrence / flotte | [F5.1 §17](../../source/production/01-runtime.md) |
| Persistance | Fiche de Registre, `LossDeclarationId`, `RestorePlanId`, `Readmitted` | registre / perte déclarée / restauration / réadmission | [F5.2 §6, §10](../../source/production/02-persistence.md) |
| Observabilité | `IncidentId`, `AlertId`, `RunbookId`, Main courante | incident / alerte / runbook / registre d'exploitation | [F5.3 §10](../../source/production/03-observability.md) |
| Sécurité | `CredentialId`, `SessionId`, `RevocationId`, `SecurityPolicyId`, `ThreatModelId`, `RiskId`, `ControlId`, `VulnerabilityId`, `SecurityReviewId`, `DisclosureId` | objets gouvernés de sécurité | [F5.4.99](../../source/production/04-security.md) |
| Fiabilité | `ChaosExperimentId`, `FaultInjectionId`, `ReprisePlanId`, `ReliabilityPolicyId`, `DegradationPolicyId`, `IsolationPolicyId`, `LoadSheddingPolicyId` | expériences & politiques de fiabilité | [F5.5 §10](../../source/production/05-reliability.md) |
| Scalabilité | `CellId`, `RegionId`, `PlacementId`, `CapacityPlanId` | contenants & actes d'exploitation | [F5.6 §4](../../source/production/06-scalability.md) |
| Opérations | `OperationalDecisionId`, `OperationalValidationId`, `ChangePlanId`, `MaintenancePlanId`, `PostmortemId`, `RCAId`, `CorrectiveTaskId`, `OperationalReviewId` | objets gouvernés d'exploitation | [F5.7.99](../../source/production/07-operations.md) |
| Gouvernance | `CorpusVersionId`, `PublicationId`, `GlossaryVersionId`, `CanonicalReleaseId`, `DocumentationAuditId`, `PublicationPackageId` | objets gouvernés du Corpus | [F5.8.99](../../source/production/08-governance.md) |

## C. Identités refusées (Procès V — non constitutionnelles)

| Refusé | Raison | Source |
|--------|--------|--------|
| `SnapshotId`, `BackupId` | mécanismes (copies internes) | [F5.99 Procès V](../../source/production/09-grand-audit.md) |
| `TrustChainId` | propriété vérifiée à chaque traversée, pas un objet | [F5.99 Procès V](../../source/production/09-grand-audit.md) |
| `DocumentationSignatureId` | attribut (une signature n'a pas d'identité propre) | [F5.99 Procès V](../../source/production/09-grand-audit.md) |
| `DiffId` | acte de vérification, pas un objet | [F5.99 Procès V](../../source/production/09-grand-audit.md) |
| `PrincipalId` | collision (Principal réservé à Foundation Layout) | [F5.99 Procès V](../../source/production/09-grand-audit.md) · [Vocabulary Diff VD-0055/VD-0094](../glossary/02-vocabulary-diff.md) |

## Références

[F3.1.99 §4](../../source/domain/01-tactical-building-blocks.md) · [F5.99 §3 Théorème des identités](../../source/production/09-grand-audit.md) · [Glossaire §G](../glossary/01-official-glossary.md) · [Vocabulary Diff §H](../glossary/02-vocabulary-diff.md).

## Notes

- Ne reçoivent **pas** d'identité : les Value Objects, les projections (recalculables), les mécanismes (remplaçables), les attributs (signature, clé), les actes de vérification (Diff), les rôles (Runtime, TrustChain) — Théorème des identités (F5.99). Dettes lexicales associées : [Vocabulary Diff §G](../glossary/02-vocabulary-diff.md).
