---
doc: canon-projection-catalogs
title: Catalogues
type: projection
titre: canon
statut: "Projeté — R2-Projections Lot 4"
corpus_ref: "foundation-v1.0.0 (8d095ee)"
proprietaire: Conseil Constitutionnel de Mentora
cree_par: "R2-Corpus Lot 1"
projete_par: "R2-Projections Lot 4"
---

# Catalogues

Contenant des **catalogues** dérivés. Chaque catalogue est une projection
déterministe de la Source : un **index** qui pointe vers la Constitution, jamais
une recopie. Chaque entrée possède un propriétaire et une référence canonique.

| # | Catalogue | Portée |
|---|-----------|--------|
| 01 | [Faits métier (Events)](01-events-catalog.md) | 73 faits |
| 02 | [Commandes (Commands)](02-commands-catalog.md) | 79 commandes |
| 03 | [Requêtes (Queries)](03-queries-catalog.md) | 11 lectures (R-C) |
| 04 | [Politiques (Policies)](04-policies-catalog.md) | 16 politiques |
| 05 | [Agrégats (Aggregates)](05-aggregates-catalog.md) | 30 unités |
| 06 | [Projections](06-projections-catalog.md) | familles + projections nommées |
| 07 | [Identités](07-identities-catalog.md) | familles domaine + production |
| 08 | [Machines d'états](08-state-machines-catalog.md) | 15 (domaine) + production |
| 09 | [Lois](09-laws-catalog.md) | F1→F5 (identifiants seuls) |
| 10 | [Théorèmes](10-theorems-catalog.md) | 15 démonstrations |
| 11 | [Chaînes de preuve](11-proof-chains-catalog.md) | 6 chaînes, 2 vestibules |
| 12 | [Anti-patterns](12-anti-patterns-catalog.md) | par couche |

> Un catalogue **indexe**, il ne décide jamais (règle N°33). Les comptes sont
> **dérivés** des énumérations (F3.3 : le catalogue fait foi, jamais le chiffre).
