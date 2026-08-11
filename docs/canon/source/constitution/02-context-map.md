---
doc: f2-02-context-map
title: F2.2 — Domain Context Map (état final ratifié)
type: source
titre: constitution
statut: "Ratifié et GELÉ — reconstruction canonique fidèle (R2-Corpus Lot 3b)"
corpus_ref: "foundation-v1.0.0 (8d095ee)"
proprietaire: Conseil Constitutionnel de Mentora
materialise_par: "R2-Corpus Lot 3b"
sources_session:
  - "F2.2 Context Map Lot 1 — Core Interaction Domains (Engagement, Consultation, Consent, Messaging)"
  - "F2.2.1 Context Map Contradiction Audit — Lot 1 (amendement : langages publiés complétés — chronologie Engagement, RencontreInterrompue, Consent à cinq faits)"
  - "F2.2 Context Map Lot 2 — Core Value Domains (Professional Identity, Reputation, Expert Economy, Augmentation ; ForecastUpdated refusé ; trois lois transversales)"
  - "F2.2 Context Map Lot 3 — Supporting & Generic Domains (Account, Discovery, Enterprise, Identity & Access, Settlement, Notification, Storage ; arête Engagement→Settlement ; loi de la connaissance des génériques)"
  - "F2.2.99 Complete Context Map Contradiction Audit (amendements : mort du SignalDeConfiance, police des registres, taxonomie possédée, RetraitÉchoué/SuiteTraitée, huitième loi ; 10 architectures rivales détruites)"
note: >-
  Reconstruction fidèle de l'état FINAL ratifié après quatre audits successifs
  (F2.1.1, F2.1.2, F2.2.1, F2.2.99). Chaque phrase provient d'une source de
  session citée. L'inventaire des 15 domaines appartient à F2.1 et n'est pas
  redupliqué : ce chapitre possède les frontières, les langages publiés, les
  événements, les dépendances, les cycles, les ACL/OHS, l'absence de Shared
  Kernel, et les lois transversales. Scaffolding de session exclu. Les noms
  d'événements sont donnés tels que publiés en session ; leur canonisation
  bilingue relève du chapitre Dictionnaire (F2.5). Titre VII pour toute évolution.
---

# F2.2 — Domain Context Map

> État **final ratifié** des relations entre les 15 domaines, après les
> amendements F2.2.1 (langages complétés) et F2.2.99 (mort des signaux de
> confiance, police des registres, taxonomie possédée, huitième loi).

## 1. La carte des patterns (Context Map)

Toute dépendance est la **consommation d'un langage publié**, en sens unique. Patterns démontrés par domaine :

### Core Interaction Domains (Lot 1)

| Domaine | Rôle / pattern | Langage publié |
|---|---|---|
| **Consent** | **Supplier** en **Open Host Service** : un contrat uniforme de faits d'autorisation pour des consommateurs nombreux et divers | accordé / refusé / retiré / expiré / invalidé — typé, porté, daté, prouvable |
| **Engagement** | **Supplier** de la Consultation (Customer/Supplier) | demandé / accepté / refusé / caduque / confirmé / replanifié / annulé / échu |
| **Consultation** | **Customer** de l'Engagement et du Consent ; **Supplier** des domaines de fruits | préparée / ouverte / clôturée / interrompue / artefact remis / suite ouverte / suite traitée |
| **Messaging** | **Separate Ways** avec les trois autres, délibéré et muré | conversation ouverte / message déposé (sans contenu) / conversation clôturée |

### Core Value Domains (Lot 2)

| Domaine | Pattern démontré | Langage publié |
|---|---|---|
| **Professional Identity** | **Supplier** (Customer/Supplier) vers Engagement et Réputation — peu de consommateurs connus : pas d'OHS. Possède le **référentiel des spécialités déclarables** | offre publiée / retirée / expertise déclarée / expérience déclarée / portfolio mis à jour / contenu de masterclass publié |
| **Reputation** | **Customer conformiste** des faits de la Consultation ; **Supplier** de la Découverte | avis publié / réponse à avis publiée / certification vérifiée / réalisation constatée / avis signalé / signalement tranché |
| **Expert Economy** | **Customer** de deux fournisseurs core ; **ACL** obligatoire devant le Règlement | revenu reconnu / revenu ajusté / retrait demandé / retrait abouti / retrait échoué / objectif déclaré |
| **Augmentation** | **Conformist** multi-sources en lecture ; en écriture, un **langage de propositions** — publié pour les personnes, interdit aux domaines comme fait | production délivrée (typée, marquée IA, citée, incertitude dite) |

### Supporting & Generic Domains (Lot 3)

| Domaine | Pattern démontré | Langage publié |
|---|---|---|
| **Account** | **OHS** — le seul OHS métier : consommateurs nombreux et hétérogènes des identifiants et préférences | personne enregistrée / préférence modifiée / joignabilité modifiée / cadre modifié / abonnement souscrit-résilié / compte fermé |
| **Discovery** | Customer conformiste de quatre fournisseurs ; Supplier des surfaces | favori ajouté-retiré / intérêt exprimé / suggestion retenue-écartée |
| **Enterprise** | Customer/Supplier des deux côtés, à sens unique | organisation créée / invitation émise-acceptée-déclinée / appartenance révoquée / parrainage accordé-retiré / vérification établie |
| **Identity & Access** *(générique)* | Supplier générique derrière l'ACL du Compte | preuve établie / preuve révoquée |
| **Settlement** *(générique)* | Supplier générique ; contrat de service neutre | ordre exécuté / ordre échoué (compte rendu au commanditaire seul) |
| **Notification** *(générique)* | Supplier générique ; **une** lecture montante sanctionnée (joignabilité) | signal livré / non livrable (au seul émetteur) |
| **Storage** *(générique)* | Supplier générique | dépôt conservé / restitué / détruit (au seul déposant) |

- **Partnership : aucun.** **Shared Kernel : aucun** (§6). **Conformist** : les consommateurs du Consent et de la Découverte adoptent le langage publié tel quel.
- **Separate Ways** : Messaging ↔ {Engagement, Consultation, Consent} — trois murs délibérés ; et Augmentation ↔ tous les domaines *en écriture* (le mur des propositions). Traversée uniquement par l'acte d'une personne.

## 2. Domain Events (état final — morts et naissances appliquées)

Loi de nommage des faits (huitième loi, F2.2.99) : **un fait naît d'un acte ou d'une décision de son propriétaire ; une dérivation déterministe est une projection, jamais un fait.**

- **Engagement** — `AccordDemandé` → `AccordAccepté` | `AccordRefusé` | `DemandeCaduque` → `AccordConfirmé` → (`AccordReplanifié`)* → `AccordAnnulé` | `AccordÉchu`. « Honoré » supprimé (lecture composée).
- **Consultation** — `RencontrePréparée` → `RencontreOuverte` → `ArtefactRemis`* → `RencontreClôturée` | `RencontreInterrompue` → `SuiteOuverte` → `SuiteTraitée`. Le no-show n'est pas un fait (lecture composée).
- **Consent** — les cinq faits : `ConsentementAccordé`, `ConsentementRefusé` (mémoire du refus définitif), `ConsentementRetiré`, `ConsentementExpiré`, `ConsentementInvalidé` (police du registre par le gardien). *(Noms d'état canonisés par le Dictionnaire : Granted / Refused / Withdrawn / Expired / Invalidated.)*
- **Messaging** — `ConversationOuverte`, `MessageDéposé` (métadonnée de signal, **jamais le contenu**), `ConversationClôturée`.
- **Professional Identity** — `OffrePubliée`, `OffreRetirée`, `ExpertiseDéclarée`, `ExpérienceDéclarée`, `PortfolioMisÀJour`, `ContenuDeMasterclassPublié`.
- **Reputation** — `AvisPublié`, `RéponseÀAvisPubliée`, `CertificationVérifiée`, `RéalisationConstatée`, `AvisSignalé`, `SignalementTranché`. **`SignalDeConfianceMisÀJour` supprimé** (F2.2.99) : un signal de confiance est une synthèse de preuves — une **projection** dépliable, jamais un fait.
- **Expert Economy** — `RevenuReconnu` (décision de reconnaissance), `RevenuAjusté`, `RetraitDemandé`, `RetraitAbouti`, `RetraitÉchoué`, `ObjectifDéclaré`. **`ForecastUpdated` refusé** : une prévision est une projection citée avec sa provenance.
- **Augmentation** — `ProductionDélivrée` (type en donnée : résumé, traduction, suggestion d'action, connaissance ; portée ; consentement de référence ; marquage IA ; incertitude déclarée). Un seul événement générique typé.
- **Account** — `PersonneEnregistrée`, `CompteFermé`, `PréférenceModifiée` (typée), `JoignabilitéModifiée`, `CadreDeDisponibilitéModifié`, `AbonnementSouscrit`, `AbonnementRésilié`. Faux événements supprimés : `EspaceDeTravailChangé`, `AbonnementÀRenouveler`, `ProfilComplété` (contextes et projections).
- **Discovery** — `FavoriAjouté`, `FavoriRetiré`, `IntérêtExprimé`, `SuggestionRetenue`, `SuggestionÉcartée` (refus-mémoire, comme `ConsentementRefusé`).
- **Enterprise** — `OrganisationCréée`, `InvitationÉmise`, `InvitationAcceptée`, `InvitationDéclinée`, `AppartenanceRévoquée` (avec l'auteur du refus), `ParrainageAccordé`, `ParrainageRetiré`, `VérificationÉtablie`.
- **Identity & Access** — `PreuveÉtablie`, `PreuveRévoquée`.
- **Settlement** — `OrdreExécuté`, `OrdreÉchoué` (au seul commanditaire, traduits par son ACL).
- **Notification** — `SignalLivré`, `SignalNonLivrable` (au seul émetteur).
- **Storage** — `DépôtConservé`, `DépôtRestitué`, `DépôtDétruit` (rétention échue, au seul déposant).

## 3. Les lectures composées (projections, jamais des faits)

Catégorie officielle de la carte : **ce qui se compose ne se possède pas.** Sont des projections, possédées par personne, calculées à la lecture et citées : « honoré », le no-show, la prévision (`Forecast`), la complétude de profil, le calendrier (cadre + accords), l'abonnement-à-renouveler, et les **signaux de confiance** (synthèses de preuves dépliables — RT-03).

## 4. Dépendances autorisées (final, tous lots)

Chacune à sens unique, adossée à un consommateur nommé d'un fait nommé :

1. **Consultation → Engagement** (accord confirmé et échu) ; jamais l'inverse (le cycle « honoré » détruit).
2. **Consultation → Consent** (refus de rencontre appliqués sur les accords actifs, fail closed) ; jamais l'inverse.
3. **Réputation → Consultation** (la preuve naît d'une rencontre réelle) ; **Réputation → Identité professionnelle** (une preuve prouve une revendication).
4. **Économie → Engagement** (confirmé/annulé/échu) ; **Économie → Consultation** (clôturée/interrompue) ; **Économie → Règlement (ACL)**.
5. **Identité professionnelle → Consent** (visibilité) ; **Identité professionnelle → Compte** (la personne).
6. **Augmentation → Consent** (fail closed) ; **Augmentation → {Consultation, Économie, Réputation, Identité}** en lecture citée (AE-06).
7. **Engagement → Identité professionnelle** (l'offre) ; **Engagement → Compte** (le cadre) ; **Engagement → Settlement (ACL)** — arête omise au Lot 1, complétée au Lot 3 (l'encaissement est une condition de `AccordConfirmé`).
8. **Découverte → {Identité pro, Réputation, Compte (cadre), Économie (opportunités)}** en lecture conformiste.
9. **Enterprise → {Compte, Engagement, Réputation (vérifications), Économie}** ; **Enterprise → Consent** (partage membre→organisation).
10. **Account → Identity & Access (ACL)** ; **Account → Settlement (ACL, abonnement)**.
11. **Notification → Account (joignabilité)** — l'unique lecture montante d'un générique, sanctionnée.
12. **Consent → Compte** (identité de la personne) uniquement.

## 5. Dépendances interdites (final)

1. **Engagement → Consultation** (cycle détruit).
2. **Messaging ↔ {Consultation, Engagement, Consent}** : deux paroles, deux propriétaires (NAV-04) ; aucune ouverture automatique — la naissance d'une conversation appartient à Messaging, sur l'acte d'une personne.
3. **Réputation → Engagement** : on réserve une offre, pas une note.
4. **Réputation → Économie** et **Économie → Réputation** : la confiance ne dérive jamais de l'argent, ni l'argent de la confiance.
5. **Identité professionnelle → Réputation** : la parole ne se règle pas sur la preuve par machinerie.
6. **Tout domaine → Augmentation** : nul ne consomme `ProductionDélivrée` comme fait ; **Augmentation → écriture où que ce soit**.
7. **Compte → tout domaine métier** ; **un générique → toute vérité métier** (sauf la joignabilité sanctionnée).
8. **Quiconque → Consent** à d'autres fins que la validité de son propre acte (aucun profilage) ; **toute mise en cache d'un accord** comme vérité locale.
9. **Quiconque → I&A comme fait métier** (« connecté » n'est pas une vérité de domaine) ; **un domaine → le compte rendu d'un générique commandé par un autre** (rapports au seul commanditaire) ; **contenu** jamais dans les signaux ni les ordres.

## 6. Cycles, ACL, OHS, Shared Kernel

- **Cycles** : **zéro**, en sept familles cherchées (directs, indirects, conceptuels, de langage, de responsabilité, de connaissance, temporels). Les trois cycles historiques (honoré ; Augmentation⇄Consultation ; Compte⇄Notification) restent morts sous leurs trois lois (projection ; pont-personne ; connaissance-dans-l'ACL).
- **Anti-Corruption Layers retenus** : Économie ⇄ Règlement ; Engagement ⇄ Settlement ; Account ⇄ Settlement ; Account ⇄ Identity & Access ; Augmentation ⇄ fournisseurs de modèles ; chaque générique ⇄ ses fournisseurs externes ; ACL devant les moteurs de recherche de la Découverte ; **anti-legacy** pour toute la migration (traduction, jamais adoption). **Aucun ACL entre domaines internes** (les langages sont conçus pour leurs consommateurs).
- **Open Host Services** : **Compte** (seul OHS métier) ; **Consent** (OHS de garde). Aucun autre.
- **Shared Kernel** : **aucun, et il ne faut surtout pas en créer** — chaque chose co-possédable s'est révélée soit un langage publié à propriétaire unique, soit une configuration de la Foundation (monnaie, montants).

## 7. Les lois transversales permanentes

Attaquées une à une et déclarées permanentes (F2.2.99 §10) :

1. **Une vérité = un propriétaire** (l'Enterprise au double NON n'est pas une exception : le lien a un propriétaire unique et deux parties refusantes).
2. **La personne est le seul pont** au-dessus des murs étanches.
3. **Ce qui se compose ne se possède pas** (les projections ne sont jamais des faits).
4. **Les propositions de l'IA ne sont jamais des faits** (l'adoption est l'acte d'une personne, constaté par le domaine adoptant).
5. **La confiance ne dérive jamais de l'argent, ni l'argent de la confiance.**
6. **Les génériques ignorent le métier** (l'unique exception sanctionnée : la joignabilité).
7. **Les comptes rendus vont au seul commanditaire.**
8. **La connaissance descendante vit dans l'ACL**, jamais dans le domaine.
9. **(Huitième loi de nommage)** Un acte ou une décision font un fait ; une dérivation déterministe fait une projection.

---

## Provenance de matérialisation (non normatif)

Reconstruction fidèle de l'état final ratifié à partir des sources de session :

- **Lot 1** (Core Interaction) : patterns et langages de Engagement, Consultation, Consent, Messaging ; suppression de l'état « honoré » (cycle détruit) ; joignabilité au Compte.
- **F2.2.1** : chronologie de l'Engagement complétée (`AccordDemandé/Accepté/Refusé/DemandeCaduque/…`) ; `RencontreInterrompue` ajouté ; Consent porté à cinq faits (`Refusé`, `Invalidé` ajoutés) ; no-show confirmé comme lecture composée.
- **Lot 2** (Core Value) : Professional Identity, Reputation, Expert Economy, Augmentation ; `ForecastUpdated` refusé ; trois lois transversales (composé ≠ possédé ; pont-personne ; confiance ⇄ argent jamais).
- **Lot 3** (Supporting & Generic) : Account, Discovery, Enterprise, I&A, Settlement, Notification, Storage ; arête `Engagement → Settlement (ACL)` complétée ; loi de la connaissance des génériques (cycle Compte⇄Notification dissous) ; trois faux événements supprimés ; `SuggestionÉcartée` érigée en refus-mémoire.
- **F2.2.99** : mort de `SignalDeConfianceMisÀJour` (projection) ; police des registres généralisée (`AvisSignalé`/`SignalementTranché`) ; référentiel des spécialités possédé par l'Identité professionnelle ; `RetraitÉchoué` et `SuiteTraitée` ajoutés ; huitième loi (acte/décision vs dérivation) ; dix architectures rivales détruites.

Le scaffolding de session (Phase 0, Blockers-processus, État Git, STOP) n'est pas reproduit. Les noms d'événements sont donnés tels que publiés en session ; leur canonisation bilingue (FR ↔ EN) relève du chapitre Dictionnaire (F2.5).
