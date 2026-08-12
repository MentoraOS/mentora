---
doc: canon-compliance-02-integrity
title: Integrity Report — Compliance Package (projection)
type: report
titre: canon
statut: "Projeté — R2-Projections Lot 5C (Compliance Package)"
corpus_ref: "foundation-v1.0.0 (8d095ee)"
proprietaire: Conseil Constitutionnel de Mentora
projete_par: "R2-Projections Lot 5C"
note: >-
  PROJECTION. Démontre, ne décide jamais (N°46). Reconstruisible (N°47). Ne produit
  aucune vérité (N°50), ne corrige rien (N°49). Empreintes content-derived
  (reproductibles). Évolution : Titre VII.
---

# Integrity Report

## Manifest

| Champ | Valeur |
|-------|--------|
| Rapport | Integrity |
| Version de corpus | `foundation-v1.0.0` (`8d095ee`) |
| Nature | démonstration d'intégrité documentaire |

## Portée

Vérifie le **Hash Manifest** (Canon Release), la cohérence des **Packages** (six
Livres) et la cohérence documentaire d'ensemble.

## Sources

[Canon Release — Hash Manifest §7](../releases/01-canon-release.md) · [`packages/`](../packages/01-foundation-book.md) · [`source/`](../../source/) · [`projection/`](../../projection/).

## Méthode

Recomputation des **SHA-1 de blob git** (`git hash-object`) des 42 documents
canoniques et comparaison au Hash Manifest ; contrôle de résolution des liens ;
vérification que chaque Livre rattache son intégrité au Hash Manifest unique
(aucune empreinte dupliquée — anti-duplication).

## Résultat

| Contrôle | Constaté |
|----------|----------|
| **Hash Manifest** — 42 documents (27 Source + 15 Projection) | **42/42 concordent** (0 écart) |
| **Canon Release** — reproductibilité | empreintes = fonction pure du contenu (N°38) |
| **Packages** — 6 Livres rattachés au Hash Manifest unique | conforme (aucune duplication d'empreinte) |
| **Cohérence documentaire** — liens internes | **résolus** (contrôle global du corpus) |
| **Baseline** — tag `foundation-v1.0.0` (`8d095ee`) | **immuable, intact** |

## Statut

**CONFORME.**

## Anomalies

**Aucune.** Toute altération d'un document changerait son empreinte ; aucune
divergence détectée.

## Conclusion

L'intégrité documentaire du Corpus est **démontrée** : chaque document canonique
correspond exactement à son empreinte content-derived ; la baseline est intacte.
Le rapport constate (N°46, N°49).
