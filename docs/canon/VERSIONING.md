---
doc: canon-versioning
title: Règles de version documentaire
type: apparatus
titre: canon
statut: "R2-Corpus Lot 1 — infrastructure"
corpus_ref: "foundation-v1.0.0 (8d095ee)"
proprietaire: Conseil Constitutionnel de Mentora
cree_par: "R2-Corpus Lot 1"
---

# Règles de version documentaire

Cinq rangs de version coexistent sans se confondre. Ils sont **documentaires** :
aucun ne modifie une décision déjà prise dans **F5** ; ils ne font que **nommer**
des états distincts.

## Les cinq rangs

| Rang | Objet versionné | Qui l'incrémente | Exemple |
|------|-----------------|------------------|---------|
| **Canonical Version** | La Constitution comme un tout gelé | **Titre VII** uniquement | `foundation-v1.0.0` |
| **Corpus Version** | L'état de matérialisation du Corpus Canonique (effort R2-Corpus) | Conseil, par lot | `corpus-0.1.0` (Lot 1) |
| **Publication Version** | Un artefact de publication émis | Autorité émettrice | `pub-2026.08.11` |
| **Release Version** | Un package de release constitué | Autorité de release | `release-1.0.0` |
| **Document Version** | Un fichier individuel | Auteur du document | `1.0.0` |

## Invariants

1. **Canonical Version ⟂ Corpus Version.** La Constitution peut être gelée
   (`foundation-v1.0.0`) pendant que sa matérialisation progresse
   (`corpus-0.1.0` → `corpus-0.2.0` → …). Matérialiser **n'amende pas** :
   remplir le contenant ne touche pas la loi.
2. La **Canonical Version** n'évolue **que** par Titre VII. Aucun lot R2-Corpus,
   aucune projection, aucune publication ne l'incrémente.
3. Une **Publication** cite toujours la **Canonical Version** qu'elle projette et
   la **Corpus Version** dont elle est tirée.
4. **Document Version ≤ portée du document** : un fichier de Source figée reste à
   `1.0.0` tant que le Titre VII ne l'a pas amendé ; une projection peut monter
   librement (régénérations).
5. Aucune version n'est jamais **réécrite** ; on incrémente, on n'efface pas.

## État au Lot 1

- **Canonical Version** : `foundation-v1.0.0` (`8d095ee`) — **gelée**.
- **Corpus Version** : `corpus-0.1.0` — infrastructure documentaire (ce lot).
  Aucun contenu de Source encore matérialisé.
- **Publication / Release Version** : la seule publication émise à ce jour est
  **PCR-001** (`ÉMIS`) ; son inscription documentaire relève de
  [`publication/reports/`](publication/reports/) aux lots ultérieurs.
