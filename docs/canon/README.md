---
doc: canon-readme
title: Corpus Canonique de Mentora — Racine documentaire
type: apparatus
titre: canon
statut: "R2-Corpus Lot 1 — infrastructure documentaire (contenant, sans contenu constitutionnel)"
corpus_ref: "foundation-v1.0.0 (8d095ee)"
proprietaire: Conseil Constitutionnel de Mentora
cree_par: "R2-Corpus Lot 1"
---

# Corpus Canonique de Mentora

`docs/canon/` est la **racine unique** du Corpus Canonique : la matérialisation
documentaire de la Constitution de Mentora déjà démontrée et gelée
(Titres **F1 → F5**, `foundation-v1.0.0`, `8d095ee`).

> Ce dossier **ne crée aucune loi, ne modifie aucune vérité, ne déplace aucune
> autorité**. Il n'est qu'une **projection gouvernée** de la Source. La Source de
> vérité demeure la Constitution ratifiée ; ce dossier en est l'attestation
> lisible.

## Statut du présent lot

Ce dossier est, à ce stade (**R2-Corpus — Lot 1**), un **contenant vide** :
l'architecture documentaire est complète, mais **aucun contenu constitutionnel
n'y est encore inscrit**. Les documents de fond (F1→F5, Glossaire, Handbook)
arriveront aux lots suivants, **sans modification future de cette architecture**.

## La colonne vertébrale

La hiérarchie documentaire respecte **exactement** l'ordre constitutionnel, et
jamais l'inverse :

```
Structure  →  Source  →  Vérification  →  Projection  →  Publication
```

| Étape | Dossier | Rôle |
|-------|---------|------|
| Structure | *(la présente arborescence + apparatus)* | le contenant officiel |
| Source | [`source/`](source/) | le Corpus Canonique lui-même (F1→F5) |
| Vérification | [`verification/`](verification/) | audits `.99` et Diff |
| Projection | [`projection/`](projection/) | Glossaire, Handbook, Catalogues, Index dérivés |
| Publication | [`publication/`](publication/) | Releases, Packages, Rapports émis |

Documents transverses : [`decisions/`](decisions/) (ADR + RFC),
[`templates/`](templates/), [`appendices/`](appendices/), [`assets/`](assets/),
[`history/`](history/).

## Points d'entrée

- **[MANIFEST.md](MANIFEST.md)** — structure officielle, familles de documents,
  propriétaires, cycles de vie.
- **[CONVENTIONS.md](CONVENTIONS.md)** — nommage, numérotation, références, ancres,
  Markdown, citation, révision.
- **[VERSIONING.md](VERSIONING.md)** — Canonical / Corpus / Publication / Release /
  Document Version.
- **[PUBLICATION.md](PUBLICATION.md)** — Source / Projection / Publication / Release /
  Package / Signature / Audit, sans confusion possible.
- **[GOVERNANCE.md](GOVERNANCE.md)** — qui peut créer, modifier, publier, signer,
  archiver, supprimer.
- **[INDEX.md](INDEX.md)** — index canonique (retrouver chaque document).
- **[NAVIGATION.md](NAVIGATION.md)** — parcours tool-independent du corpus.

## Rapport avec le tissu documentaire hérité

Les dossiers `docs/architecture/`, `docs/baseline/`, `docs/philosophy/` et
`docs/governance/` **antérieurs à la Foundation** demeurent inchangés, comme
artefacts historiques. Leur éventuel versement sélectif dans
[`history/`](history/) est une **dette ultérieure**, hors périmètre du Lot 1.
