---
doc: canon-freeze-03-canon-signature
title: Canon Signature — Publication Freeze (sceau de provenance content-derived)
type: release
titre: canon
statut: "Projeté — R2-Projections Lot 5D (Publication Freeze)"
corpus_ref: "foundation-v1.0.0 (8d095ee)"
proprietaire: Conseil Constitutionnel de Mentora
projete_par: "R2-Projections Lot 5D"
canon_signature: "9ea3d7ee760aaa4de71377e55d85004991bcefe8"
note: >-
  ATTESTATION. Une signature certifie une publication, jamais la Constitution
  (N°52, N°39). Ceci est un SCEAU DE PROVENANCE content-derived (empreinte agrégée
  reproductible), non une signature personnelle : l'acte constitutionnel de
  signature/émission appartient au CTO (comme pour PCR-001). Reproductible, sans
  donnée volatile (N°47). Évolution : Titre VII.
---

# Canon Signature

## Manifest

| Champ | Valeur |
|-------|--------|
| Document | Canon Signature |
| Nature | sceau de provenance content-derived (atteste ; N°51) |

## Identité

| Champ | Valeur |
|-------|--------|
| `CanonSignature` (sceau) | `9ea3d7ee760aaa4de71377e55d85004991bcefe8` |
| `CanonicalReleaseId` | `canon-release-1.0.0` |
| `CorpusVersionId` | `foundation-v1.0.0` (`8d095ee`) |

## Portée

Scelle la **provenance exacte** de la publication : les **42 documents canoniques**
(27 Source + 15 Projection). Le sceau certifie **cette publication**, jamais la
Constitution (N°52).

## Version

`foundation-v1.0.0` (`8d095ee`).

## Références

[Publication Certificate](02-publication-certificate.md) · [Canon Release — Hash Manifest §7](01-canon-release.md) · [Source](../../source/) · [Projection](../../projection/).

## Vérification

Le sceau est **reproductible** (N°47) — fonction pure du contenu. Commande de
recomputation :

```bash
git ls-files -s docs/canon/source docs/canon/projection \
  | grep -v README | awk '{print $2"  "$4}' | sort | git hash-object --stdin
```

Résultat attendu : **`9ea3d7ee760aaa4de71377e55d85004991bcefe8`**. Toute
altération d'un des 42 documents change le sceau.

## Certification

Ce sceau **atteste la provenance** de la publication `canon-release-1.0.0`. Il
**certifie la publication, jamais la Constitution** (N°52, N°39). L'**acte
constitutionnel de signature et d'émission** appartient au **CTO** (Hamidou Bana
Diallo), comme pour le Production Closure Report (PCR-001) — ce document ne s'y
substitue pas ; il fournit l'empreinte vérifiable que cet acte peut certifier.

## Statut

**SCELLÉ — provenance attestée.**
