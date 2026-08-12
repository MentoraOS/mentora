---
doc: canon-compliance-05-projection-consistency
title: Projection Consistency Report — Compliance Package (projection)
type: report
titre: canon
statut: "Projeté — R2-Projections Lot 5C (Compliance Package)"
corpus_ref: "foundation-v1.0.0 (8d095ee)"
proprietaire: Conseil Constitutionnel de Mentora
projete_par: "R2-Projections Lot 5C"
note: >-
  PROJECTION. Démontre, ne décide jamais (N°46). Reconstruisible (N°47). Ne produit
  aucune vérité (N°50), ne corrige aucune anomalie (N°49). Chaque anomalie porte une
  identité permanente `CMP-NNNN` (N°48). Évolution : Titre VII.
---

# Projection Consistency Report

## Manifest

| Champ | Valeur |
|-------|--------|
| Rapport | Projection Consistency |
| Version de corpus | `foundation-v1.0.0` (`8d095ee`) |
| Nature | démonstration de cohérence entre projections |

## Portée

Vérifie l'absence de contradiction entre : **Glossaire, Vocabulary Diff, Handbook,
Catalogues, Canon Release, Livres**.

## Sources

[Glossaire](../../projection/glossary/01-official-glossary.md) · [Vocabulary Diff](../../projection/glossary/02-vocabulary-diff.md) · [Handbook](../../projection/handbook/01-official-handbook.md) · [Catalogues](../../projection/catalogs/01-events-catalog.md) · [Canon Release](../releases/01-canon-release.md) · [Livres](../packages/01-foundation-book.md).

## Méthode

Comparaison des comptes et des termes entre projections ; contrôle que chaque Livre
ne référence que des documents existants ; contrôle des `VD-NNNN` (identités
lexicales permanentes) ; résolution des liens.

## Résultat

| Contrôle | Constaté |
|----------|----------|
| Comptes Catalogues ↔ F3.3 (73/79/11/16/30/15/18) | cohérents (dérivés) |
| Termes Glossaire ↔ Vocabulary Diff | cohérents (mêmes réservés/interdits, `VD-NNNN`) |
| Handbook → renvois vers la Source | cohérents (aucune règle reformulée) |
| Livres → documents composés | tous existants (aucune référence pendante) |
| Canon Release → Hash Manifest | 42/42 concordent |
| Liens internes | **résolus** |

**Aucune contradiction entre projections.**

## Statut

**CONFORME** — sous réserve des dettes lexicales **gouvernées** ci-dessous
(non bloquantes).

## Anomalies (constatées, jamais corrigées — N°49 ; identités permanentes — N°48)

| ID | Constat | Renvoi (Source / projection) | Sévérité |
|----|---------|------------------------------|----------|
| **CMP-0001** | Dettes lexicales ouvertes (inscription « propriété émergente » ; bannir `PrincipalId` ; refuser `SnapshotId`/`BackupId`/`TrustChainId`/`DocumentationSignatureId`/`DiffId` ; expliciter `FleetId` ; désambiguïser `OperationalPublicationId`/`CanonicalPublicationId`) | [Vocabulary Diff §G — VD-0093→VD-0098](../../projection/glossary/02-vocabulary-diff.md) | dette gouvernée (non bloquant) |
| **CMP-0002** | Ambiguïtés lexicales signalées (« Review » : Avis / revue d'exploitation ; « Publication » : trois espèces) | [Vocabulary Diff §E — VD-0077, VD-0078](../../projection/glossary/02-vocabulary-diff.md) | signalée, non résolue (résolution due au Titre VII) |

*Ces items sont **déjà identifiés et tracés** dans la Source/projections ; le
Compliance Package les **constate**, il ne les résout jamais (N°49). Leur
résolution appartient à la fusion du Glossaire et au Titre VII.*

## Conclusion

Les projections sont **mutuellement cohérentes** ; les seules réserves sont des
**dettes lexicales gouvernées** déjà tracées (CMP-0001, CMP-0002), non bloquantes.
Le rapport constate (N°46, N°50).
