# Definition of Done — Mentora (officielle)

**Statut** : standard officiel (CTO, 2026-08-19) · Une seule DoD, à quatre niveaux emboîtés. Rien n'est « done » sans **preuve observable** ; rien n'est « done » avec une invention du Corpus.

## Niveau 1 — Une Task est done quand
1. Le code applique une loi **citée** (numéro de loi ou section du Canon dans le commentaire de tête du module).
2. Les tests de sa couche passent et la **couverture du paquet reste ≥ 95/95/95**.
3. `pnpm lint` + `typecheck` verts (MENTORA0001 vocabulaire, MENTORA0003 faits, boundaries).
4. Aucun `TODO/FIXME` ; tout différé est un commentaire **nommé** (story, RFC, lot).

## Niveau 2 — Une Story est done quand
1. Toutes ses tasks sont done **ou** déférées par écrit (story rattachée + justification canon/ordre).
2. Elle est livrée par une PR fusionnée sur `develop` avec checks requis verts et trace de bypass (tant que le compte est unique).
3. Son commentaire de fermeture cite : PR + SHA, lois appliquées, tests nommés, déférements.
4. Si elle a touché un contrat publié : l'évolution est additive (V-2) et la validation par type liste toutes les violations.
5. Si elle a touché la persistance : **les contract suites rejouent vertes sur le moteur réel**.

## Niveau 3 — Une Feature est done quand
1. Toutes ses stories sont done ou déférées par écrit.
2. La **Domain Checklist** est cochée, preuves à l'appui, dans le commentaire de fermeture.
3. Aucun STOP ouvert sans dossier d'instruction (RFC) déposé et référencé.
4. Le commentaire de fermeture porte la **déclaration officielle** (périmètre livré / déféré).

## Niveau 4 — Un Domaine est done (« Production Ready ») quand
1. Toutes ses Features sont done.
2. Les cinq paquets + la composition existent selon le modèle de référence (handbook §0) et le Root les boote fail closed.
3. La **Production Readiness Checklist** est satisfaite ; les sections non satisfaites sont **PARTIAL/FAIL au certificat**, jamais tues.
4. Le **certificat de complétion** est posté sur l'Epic (critères, couverture calculée, PR ouvertes réelles, Known Limitations réelles, Approved By, date, chaîne de preuve) et ratifié par le CTO.
5. Le domaine est **copiable** : README par paquet, dérivations et trous enregistrés, aucune exception locale non documentée.

## Ce qui n'est jamais done
- Un code qui complète le Corpus (nom, commande, fait, Query inventés).
- Un test qui passe en trichant (fournisseur réel en CI, horloge ambiante, matière en clair, `skip` silencieux).
- Une PR fusionnée rouge, sans trace, ou qui touche le canon sans label `titre-vii`.
- Un « done » sans preuve, un déférement sans écrit, un certificat optimiste.
