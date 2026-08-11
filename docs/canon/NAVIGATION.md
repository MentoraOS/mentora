---
doc: canon-navigation
title: Navigation canonique
type: apparatus
titre: canon
statut: "R2-Corpus Lot 1 — infrastructure"
corpus_ref: "foundation-v1.0.0 (8d095ee)"
proprietaire: Conseil Constitutionnel de Mentora
cree_par: "R2-Corpus Lot 1"
---

# Navigation canonique

Ce document permet de parcourir l'ensemble du corpus **sans ambiguïté** et
**sans dépendre d'aucun outil** : uniquement des chemins relatifs et des titres
stables. Il doit rester valide même après vingt ans.

## Parcours par la colonne vertébrale

Suivre l'ordre constitutionnel, **jamais l'inverse** :

```
1. Structure   → vous êtes ici (docs/canon/, MANIFEST, CONVENTIONS)
2. Source      → source/       (F1 → F2 → F3 → F4 → F5)
3. Vérification→ verification/ (audits .99, puis Grand Audit F5.99)
4. Projection  → projection/   (glossary, handbook, catalogs, indexes)
5. Publication → publication/  (reports, releases, packages)
```

## Parcours par Titre (Source)

1. **F1 — Foundation** → [`source/foundation/`](source/foundation/)
2. **F2 — Constitution** → [`source/constitution/`](source/constitution/)
3. **F3 — Domaine** → [`source/domain/`](source/domain/)
4. **F4 — Exécution** → [`source/application/`](source/application/)
5. **F5 — Production** → [`source/production/`](source/production/)

Chaque Titre est suivi de son audit `.99` dans
[`verification/audits/`](verification/audits/) ; le **Grand Audit F5.99**
(douze procès) y clôt la vérification.

## Parcours par question fréquente

| Je cherche… | J'ouvre… |
|-------------|----------|
| La définition officielle d'un mot | [`projection/glossary/`](projection/glossary/) |
| Comment appliquer une loi au quotidien | [`projection/handbook/`](projection/handbook/) |
| La preuve qu'un Titre résiste | [`verification/audits/`](verification/audits/) |
| Ce qui a changé entre deux états | [`verification/diffs/`](verification/diffs/) |
| Une décision d'architecture et ses alternatives | [`decisions/adr/`](decisions/adr/) |
| L'attestation de clôture (PCR-001) | [`publication/reports/`](publication/reports/) |
| Qui a le droit de faire quoi | [GOVERNANCE.md](GOVERNANCE.md) |

## Règle de navigation

Toute page cite en frontmatter sa **référence de corpus**
(`foundation-v1.0.0` / `8d095ee`) et, si elle projette la Source, l'**identifiant
F** exact de ce qu'elle projette. Un lecteur peut ainsi toujours **remonter à la
Source** depuis n'importe quelle projection.
