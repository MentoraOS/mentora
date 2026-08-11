---
doc: canon-conventions
title: Conventions documentaires officielles
type: apparatus
titre: canon
statut: "R2-Corpus Lot 1 — infrastructure"
corpus_ref: "foundation-v1.0.0 (8d095ee)"
proprietaire: Conseil Constitutionnel de Mentora
cree_par: "R2-Corpus Lot 1"
---

# Conventions documentaires officielles

Ces conventions régissent la **forme** de tout document du Corpus Canonique.
Elles n'introduisent **aucune loi de fond** et **aucun terme réservé** ; elles
fixent uniquement une écriture stable, lisible et valide dans vingt ans.

## 1. Nommage

- **Répertoires** : `kebab-case`, en anglais (identifiant technique stable).
- **Documents d'appareil** (racine `canon/`) : `MAJUSCULES.md`.
- **Documents de contenu** : `NN-titre-kebab.md`, où `NN` est un numéro d'ordre
  à deux chiffres au sein de la section.
- **Langue** : identifiants de fichiers et d'ancres en **anglais** ; prose
  constitutionnelle en **français**. (Conforme à la règle bilingue :
  identifiants EN, métier FR.)

## 2. Numérotation

- Les Titres conservent leurs identifiants **F-numérotés** officiels
  (`F1`, `F2`, …, `F5`) et leurs chapitres (`F5.1`, `F3.2-A`, …). **Ces
  identifiants ne sont jamais renommés** par la documentation.
- Les documents d'une section sont préfixés `NN-` pour l'ordre de lecture ; le
  préfixe est **cosmétique**, jamais un identifiant constitutionnel.

## 3. Versions

Voir [VERSIONING.md](VERSIONING.md). Chaque document porte une `Document Version`
en frontmatter ; les versions de plus haut rang (Canonical, Corpus, Publication,
Release) sont définies au niveau du corpus, pas du fichier isolé.

## 4. Références

- Toute référence à la Source cite l'**identifiant F** exact
  (ex. « conformément à **F5.8** »), jamais un libellé pédagogique.
- Toute référence externe au corpus cite la **référence de corpus**
  (`foundation-v1.0.0` / `8d095ee`).
- Une référence ne **copie jamais** le contenu cité : elle **pointe** (principe
  de provenance — on cite un identifiant stable, on ne duplique pas une vérité).

## 5. Liens internes

- Liens **relatifs** uniquement (aucune URL absolue, aucun outil requis).
- Cible : chemin relatif + ancre si nécessaire. Exemple de forme (illustratif,
  la cible sera matérialisée aux lots ultérieurs) :
  `[F5.8 — PG-1](source/production/08-governance.md#pg-1)`.
- Un lien cassé est un **défaut de conformité** détectable structurellement.

## 6. Ancres

- Ancres en `kebab-case` ASCII, dérivées du titre de section.
- Les identifiants de lois/théorèmes servent d'ancres stables
  (`#pg-1`, `#loi-a-5`, `#theoreme-residence`).

## 7. Markdown

- Markdown standard (CommonMark + tableaux GFM). Aucun greffon propriétaire.
- Un seul `# H1` par document ; hiérarchie stricte `#` → `##` → `###`.
- **Frontmatter YAML** obligatoire (voir §10).
- Blocs de code clôturés par ``` avec langage explicite quand pertinent.

## 8. Citation

- Une citation de la Source est **littérale**, entre guillemets, **attribuée**
  à son identifiant F.
- Une projection **paraphrase** la Source de façon déterministe ; en cas de
  divergence, la Source prévaut toujours.

## 9. Révision

- Toute révision d'un document de **Source** suit la procédure du **Titre VII**.
- Toute révision d'une **projection** est une **régénération**, pas une retouche.
- L'historique des révisions vit dans le contrôle de version (`git`) et, pour les
  jalons, dans [`history/`](history/).

## 10. Frontmatter minimal obligatoire

```yaml
---
doc: <identifiant-technique-unique>
title: <titre lisible>
type: source | audit | diff | projection | publication | decision | apparatus | template
titre: foundation | constitution | domain | application | production | canon
statut: <état de cycle de vie>
corpus_ref: "foundation-v1.0.0 (8d095ee)"
proprietaire: <autorité propriétaire>
version: <Document Version>       # optionnel au Lot 1
---
```

## 11. Publication

Voir [PUBLICATION.md](PUBLICATION.md) : la distinction Source / Projection /
Publication / Release / Package / Signature / Audit est **impérative** et ne
souffre aucune confusion.
