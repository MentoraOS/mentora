---
doc: canon-manifest
title: Manifest documentaire du Corpus Canonique
type: apparatus
titre: canon
statut: "R2-Corpus Lot 1 — infrastructure"
corpus_ref: "foundation-v1.0.0 (8d095ee)"
proprietaire: Conseil Constitutionnel de Mentora
cree_par: "R2-Corpus Lot 1"
---

# Manifest documentaire

Le Manifest définit **la structure officielle** du Corpus Canonique : les
familles de documents, leurs responsabilités, leurs relations, leurs
propriétaires, leurs cycles de vie et leurs règles d'évolution — **sans créer
une seule loi nouvelle**. Il décrit un contenant ; il ne légifère pas.

## 1. Structure officielle

```
docs/canon/
├── README.md              Point d'entrée
├── MANIFEST.md            Ce document
├── CONVENTIONS.md         Conventions documentaires
├── VERSIONING.md          Règles de version documentaire
├── PUBLICATION.md         Objets de publication
├── GOVERNANCE.md          Gouvernance documentaire
├── INDEX.md               Index canonique
├── NAVIGATION.md          Navigation canonique
│
├── source/                SOURCE — le Corpus Canonique (F1→F5)
│   ├── foundation/        F1 — Foundation
│   ├── constitution/      F2 — Constitution stratégique
│   ├── domain/            F3 — Domaine tactique
│   ├── application/       F4 — Exécution
│   └── production/        F5 — Production
│
├── verification/          VÉRIFICATION
│   ├── audits/            Audits .99 (par Titre) + Grand Audit
│   └── diffs/             Constitutional Diff, Vocabulary Diff
│
├── projection/            PROJECTION (dérivée, jamais Source)
│   ├── glossary/          Glossaire Officiel (bilingue)
│   ├── handbook/          Handbook Officiel
│   ├── catalogs/          Catalogues
│   └── indexes/           Index dérivés
│
├── publication/           PUBLICATION
│   ├── releases/          Releases
│   ├── packages/          Packages (dont Production Closure Package)
│   └── reports/           Rapports émis (dont PCR)
│
├── decisions/             DÉCISIONS gouvernées
│   ├── adr/               Architecture Decision Records
│   └── rfc/               Requests for Comments
│
├── templates/             Modèles vides officiels
├── appendices/            Appendices
├── assets/                Ressources (schémas, figures)
└── history/               Historique et versements
```

## 2. Familles de documents

| Famille | Emplacement | Nature | Peut créer une loi ? |
|---------|-------------|--------|----------------------|
| **Source constitutionnelle** | `source/` | Titres F1→F5 ratifiés | Oui — **via Titre VII uniquement** |
| **Audit** | `verification/audits/` | Constat contradictoire `.99` | Non (constate) |
| **Diff** | `verification/diffs/` | Comparaison de deux états | Non (constate une différence) |
| **Projection** | `projection/` | Dérivée déterministe de la Source | **Jamais** |
| **Publication** | `publication/` | Émission datée et gouvernée | Non (émet, ne fonde pas) |
| **Décision** | `decisions/` | ADR / RFC gouvernés | Amende **via Titre VII** |
| **Appareil** | racine `canon/` | Contenant, conventions | Non (organise) |
| **Template** | `templates/` | Structure vide | Non (forme sans fond) |

## 3. Responsabilités (résumé — voir [GOVERNANCE.md](GOVERNANCE.md))

- **Source** appartient au **Conseil Constitutionnel** ; toute évolution passe
  par le **Titre VII** (procédure d'amendement).
- **Projection** n'appartient à personne comme vérité : elle est **régénérable**
  et **jetable**. Une projection qui contredit la Source est fausse par
  construction — c'est la Source qui a raison.
- **Publication** est un **acte d'autorité daté** (voir [PUBLICATION.md](PUBLICATION.md)).

## 4. Relations (invariants documentaires)

1. **Source → Projection** est à sens unique. Une projection ne modifie jamais
   sa Source.
2. **Vérification** compare deux objets déjà existants ; elle n'en crée aucun.
3. **Publication** référence toujours une Source figée et une version
   canonique ; elle ne se substitue jamais à la Source.
4. Tout document cite sa **référence de corpus** (`foundation-v1.0.0` / `8d095ee`)
   dans son frontmatter.

## 5. Cycles de vie

```
Rédaction  →  Vérification (.99)  →  Ratification  →  Gel (Titre VII ouvert)
                                                   ↘  Projection / Publication
```

- **Source** : une fois ratifiée et gelée, n'évolue que par **Titre VII**.
- **Projection** : `Régénérée` à volonté ; jamais « corrigée » à la main contre
  la Source.
- **Publication** : `Préparée` → **signée** → `Émise` → (`Archivée`). L'émission
  est l'effet de la signature, jamais son préalable — voir le cas **PCR-001**.

## 6. Règles d'évolution

- Ajouter un document **n'ajoute jamais une loi** : soit c'est de la Source
  amendée par Titre VII, soit c'est une projection/publication/décision.
- L'**architecture** de ce Manifest est stable : les lots R2-Corpus suivants
  **remplissent** cette structure, ils ne la **redessinent** pas.
- Toute exception se traite par **RFC** puis, si elle touche la Source, par
  **Titre VII**.
