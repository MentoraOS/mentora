---
doc: canon-governance
title: Gouvernance documentaire
type: apparatus
titre: canon
statut: "R2-Corpus Lot 1 — infrastructure"
corpus_ref: "foundation-v1.0.0 (8d095ee)"
proprietaire: Conseil Constitutionnel de Mentora
cree_par: "R2-Corpus Lot 1"
---

# Gouvernance documentaire

Qui peut agir sur les documents du Corpus Canonique. Ces règles **restituent**
la répartition d'autorité déjà gelée (Conseil rédige et certifie ; CTO exerce
les actes d'autorité ; Titre VII gouverne l'amendement). Elles **ne créent
aucune autorité nouvelle**.

## Autorités reconnues

- **Conseil Constitutionnel de Mentora** — rédige, vérifie, certifie la
  conformité, projette. Ne signe pas les actes d'autorité.
- **CTO (autorité de signature)** — accomplit les actes d'autorité : signature,
  émission, ouverture de Titre. Précédent : **PCR-001**.
- **Titre VII (procédure d'amendement)** — seule voie de modification de la
  **Source** gelée.

## Matrice des droits

| Action | Source (F1→F5) | Projection | Publication | Décision (ADR/RFC) |
|--------|----------------|------------|-------------|--------------------|
| **Créer** | Titre VII | Conseil | Conseil (prépare) | Conseil (propose) |
| **Modifier** | Titre VII | Régénérer (Conseil) | Interdit (émettre une nouvelle version) | Via RFC / Titre VII |
| **Publier** | — | — | **CTO** (signe → émet) | Conseil |
| **Signer** | — | — | **CTO** | CTO si effet d'autorité |
| **Archiver** | Interdit (la Source ne s'archive pas ; elle se gèle) | Conseil | Conseil | Conseil |
| **Supprimer** | **Jamais** | Régénérable donc jetable | **Jamais** (une publication émise est un fait daté) | Jamais (superseded, non supprimé) |

## Principes de gouvernance

1. **La Source ne se supprime ni ne s'écrase jamais.** Elle se gèle ; elle
   n'évolue que par Titre VII, qui inscrit une nouvelle Canonical Version.
2. **Une projection est jetable** parce qu'elle est **régénérable** à partir de
   la Source. La supprimer ne perd aucune vérité.
3. **Une publication émise est un fait daté** : elle ne se supprime pas ; on
   émet, le cas échéant, une publication qui la remplace (`superseded`).
4. **Rien ne meurt sans témoin** : tout retrait ou remplacement laisse une trace
   dans le contrôle de version et, pour les jalons, dans [`history/`](history/).
5. **Séparation acte / rédaction** : le Conseil rédige et certifie ; seul le CTO
   signe. Aucun document ne peut se signer lui-même.
6. **La matérialisation n'a aucun pouvoir éditorial.** La reconstruction ou la
   transcription d'un chapitre de Source **reproduit exclusivement la dernière
   source ratifiée**. Aucun autre document — brief, résumé, note, mémoire ou
   échange ultérieur — n'a autorité sur le Corpus tant qu'un amendement du
   **Titre VII** n'a pas été ratifié. Une différence entre la Source et une telle
   paraphrase est une **différence de source documentaire**, jamais une erreur de
   la Constitution : la Source prévaut, la différence est documentée.

## Cycle d'un document de publication

```
Conseil prépare (PRÊT)  →  CTO signe (acte)  →  ÉMIS  →  (Archivé | Superseded)
```

Voir [PUBLICATION.md](PUBLICATION.md) pour la distinction des objets et
[VERSIONING.md](VERSIONING.md) pour les rangs de version.
