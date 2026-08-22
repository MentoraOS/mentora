# RFC-002 — Le droit d'émettre une Command sur l'unité d'autrui (grille de droits d'émission)

**Dossier d'instruction Titre VII** · Statut : **RATIFIÉE — Option C immédiatement, puis Option A comme architecture définitive (décision CTO du 2026-08-19)** · Le gateway reste seul responsable de la protection de l'entrée ; les domaines restent propriétaires de leurs décisions métier · Option A s'instruit avec l'ACL du Compte (FEATURE-A05) et le lot adversarial #121-#123 (Sprint 5)

> **Ratification** — Option C est en vigueur dans le code (tables d'admission du gateway : les verbes Credential/Session ne sont pas admis — porte fermée 404). Option A (grille d'émission comme validité de source au pas 5, chez le propriétaire ; famille de refus à trancher au dictionnaire) est la cible, livrée avec la jonction preuve↔personne d'A05. Le CTO n'est plus à solliciter sur cette RFC.

## Problème

M-10 ferme la liste des **émetteurs** de Commands, et M-9 borne le gateway à la session (« le droit métier ne se juge qu'au dispatch et chez le propriétaire »). Or le corpus matérialisé ne déclare de **grilles de droits que pour les lectures** (R-C, F3.3 §5 : « ayant droit » par Query). Pour les Commands, la Séquence injecte l'ActorRef au pas 5 (`validate(wire, instant, actor)` — A-6) mais **aucune loi ne dit quel acteur peut émettre quelle Command sur quelle unité**. Conséquence concrète au gateway : un acteur authentifié pourrait commander `EndSession`/`RevokeSession` sur la session d'un AUTRE, ou `CancelAgreement` sur l'accord d'autrui — l'unité ne connaît pas la personne (la Session ne porte qu'un `CredentialId` ; le lien preuve↔personne vit dans l'ACL du Compte).

## Contraintes constitutionnelles citées

- **M-9/F4.3.99** : le gateway est borné à la session — y juger un droit = « un droit dupliqué qui divergera ».
- **T-9/T-10** : l'autorisation est distribuée chez les propriétaires ; PDP = PEP, fail closed, aucun cache de décision.
- **T-13** : les tokens portent des claims prouvés, jamais des droits — le droit se calcule à la source.
- **Loi 15** : les validités de source sont synchrones au pas 5 ; les paramètres étrangers sont **fournis en données**, jamais cherchés.
- **F4.1 §5** : « l'identité injectée » entre au pas 5 — la couture existe déjà, inutilisée.

## Options instruites

**Option A — La grille d'émission est une validité de source (pas 5, chez le propriétaire de l'acte)** : chaque contexte déclare, par Command, sa règle d'émission (ex. Session : « l'émetteur des verbes de session est la personne dont la preuve porte la session visée ») ; le porteur (Application Service) précharge la donnée de jonction nécessaire (session→credential→personne, via ses capacités de lecture) et la FOURNIT EN DONNÉE au pas 5 qui refuse motivé (famille de refus à trancher au dictionnaire — candidat : la voix R-C « RightMissing » étendue aux émissions, OU une famille propre). + : PDP=PEP au propriétaire, gateway intact, fail closed ; − : amendement du plug (le pas 5 doit recevoir la donnée de jonction) — expansion additive comme RFC-001.

**Option B — Le gateway restreint les verbes de session à la chaîne présentée** : ne dispatcher `EndSession`/`RevokeSession` que vers les sessions de la MÊME personne que la session présentée. − : c'est un droit jugé au gateway (M-9 violé, dupliquera) ; ne couvre pas les Commands des autres domaines. **Rejetée par l'instruction.**

**Option C — Statu quo scellé** : les verbes concernés restent NON EXPOSÉS au gateway (porte fermée, 404) jusqu'à la ratification d'une grille. + : zéro invention, zéro trou ; − : « déconnecter cet appareil » n'est pas offert à la surface.

## Recommandation de l'instruction

**Option C IMMÉDIATEMENT (appliquée au lot gateway : les tables d'admission du gateway n'admettent ni les verbes de session ni les verbes Credential), puis Option A comme cible** — instruite avec le dictionnaire (le nom de la famille de refus d'émission doit être tranché, jamais inventé) et livrée avec le lot durcissement (Sprint 5, #121-#123) ou l'ouverture d'Account (l'ACL apporte la jonction preuve↔personne).

**Décision demandée au CTO** : ratifier Option C-puis-A (ou trancher autrement). Jusqu'à ratification : aucune grille d'émission codée ; les portes concernées restent fermées.
