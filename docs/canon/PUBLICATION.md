---
doc: canon-publication
title: Objets de publication — Source, Projection, Publication, Release, Package, Signature, Audit
type: apparatus
titre: canon
statut: "R2-Corpus Lot 1 — infrastructure"
corpus_ref: "foundation-v1.0.0 (8d095ee)"
proprietaire: Conseil Constitutionnel de Mentora
cree_par: "R2-Corpus Lot 1"
---

# Objets de publication

Sept objets doivent rester **absolument distincts**. Les confondre serait
recréer, dans la documentation, l'erreur que la Constitution interdit partout
ailleurs : confondre l'acte et son effet, la source et sa projection. Ces
définitions **restituent** des distinctions déjà gelées (notamment **F5.8**) ;
elles n'en créent aucune.

## Les sept objets

| Objet | Définition | Peut fonder une vérité ? |
|-------|------------|--------------------------|
| **Source** | Le texte constitutionnel ratifié (F1→F5). L'unique lieu de vérité. | Oui — via Titre VII |
| **Projection** | Dérivation **déterministe** de la Source (Glossaire, Handbook, Index, Catalogue). | **Jamais** |
| **Publication** | Acte **daté** rendant une projection ou un rapport officiellement disponible. | Non |
| **Release** | Ensemble cohérent de publications figées sous une **Release Version**. | Non |
| **Package** | Assemblage matériel d'une release (fichiers, artefacts) prêt à distribuer. | Non |
| **Signature** | **Acte d'autorité** qui émet ; l'effet (émission) suit toujours l'acte. | Non (autorise l'effet) |
| **Audit** | Constat **contradictoire** vérifiant un objet existant (`.99`). | Non (constate) |

## Chaîne canonique

```
Source ──(dérivation déterministe)──▶ Projection
Projection ──(acte daté)──▶ Publication
Publication ──(regroupement figé)──▶ Release ──(assemblage)──▶ Package
Signature ──(acte d'autorité)──▶ émet Publication / Release / Package
Audit ──(constat)──▶ atteste, ne crée pas
```

## Invariants impératifs

1. **Une projection ne modifie jamais sa Source.** Si elles divergent, la Source
   a raison et la projection est régénérée.
2. **La Signature précède son effet.** Un document `PRÊT POUR SIGNATURE` ne peut
   se déclarer `ÉMIS` : l'émission est l'**effet** de la signature. Le
   précédent de référence est **PCR-001**, dont l'état n'a basculé à `ÉMIS`
   qu'après l'acte d'autorité du CTO.
3. **Un Audit ne crée rien.** Il compare, constate, atteste. Il ne fonde aucune
   loi et ne signe aucune émission.
4. **Une Release est figée.** On n'y ré-écrit pas une publication : on émet une
   nouvelle Release Version.
5. **Aucune confusion de rang.** Un Package n'est pas une Source ; un Handbook
   (projection) n'est pas la Constitution (Source).

## Emplacements

- Projections → [`projection/`](projection/)
- Publications, Releases, Packages, Rapports → [`publication/`](publication/)
- Audits → [`verification/audits/`](verification/audits/)
- Signatures → attestées dans le rapport signé lui-même
  (ex. PCR sous [`publication/reports/`](publication/reports/)).
