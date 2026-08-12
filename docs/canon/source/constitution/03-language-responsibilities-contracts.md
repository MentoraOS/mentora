---
doc: f2-03-language-responsibilities-contracts
title: F2.3 + F2.4 + F2.5 — Ubiquitous Language • Domain Responsibilities • Public Contracts (état final ratifié)
type: source
titre: constitution
statut: "Ratifié et GELÉ — reconstruction canonique fidèle (R2-Corpus Lot 3c)"
corpus_ref: "foundation-v1.0.0 (8d095ee)"
proprietaire: Conseil Constitutionnel de Mentora
materialise_par: "R2-Corpus Lot 3c"
sources_session:
  - "F2.3 + F2.4 + F2.5 — Ubiquitous Language • Domain Responsibilities • Public Contracts (chapitre combiné : langage, responsabilités, contrats ; lois 10-13 ; renommage Signalement→Notification)"
  - "F2.9 — Architecture Constitution (ratifie et annexe F2.4/F2.5 avec force constitutionnelle ; n'amende aucun contenu de F2.3/4/5)"
note: >-
  Reconstruction fidèle de l'état final ratifié. Le chapitre combiné (turn
  source) n'a été amendé par aucun audit ultérieur : F2.9 l'a ratifié et a
  élevé F2.4/F2.5 au rang d'annexe constitutionnelle, sans en changer le
  contenu. Les définitions formelles des termes transversaux vivent dans F2.9
  Titre V (chapitre 06) ; la correspondance bilingue FR↔EN vit dans le
  Dictionnaire (chapitre 04) — ni l'un ni l'autre n'est dupliqué ici. Une
  variante d'un nom d'événement (propriété de F2.2) est réconciliée au
  propriétaire et signalée. Scaffolding de session exclu. Titre VII pour toute
  évolution.
---

# F2.3 + F2.4 + F2.5 — Ubiquitous Language • Domain Responsibilities • Public Contracts

> État **final ratifié**. F2.9 a annexé les chartes de F2.4 et les contrats de
> F2.5 à la Constitution **avec force constitutionnelle**.

---

# Partie A — F2.3 Ubiquitous Language

## A.1 Lois du langage (transversales)

- **Un concept = un nom = un sens.** Tout synonyme est interdit : on ne « varie » jamais le vocabulaire.
- **Un mot nu ambigu est interdit.** Là où deux domaines se côtoient, la qualification est obligatoire (« la Demande d'accord », jamais « la demande »).
- **Le langage ignore les écrans.** Aucun nom de surface (page, dashboard, inbox, feed, modal) n'entre dans le langage métier.
- **Le langage ignore la technique.** API, base, service, backend, cache, token, push, upload : interdits hors conversations d'outillage.
- **Les mots du legacy sont remplacés, jamais adoptés** : user, booking, wallet, chat, session (hors I&A), login, settings, ticket — bannis ; leur traduction est l'affaire des ACL, y compris linguistiquement.

## A.2 Vocabulaire transversal officiel

Le **Fait** (acte ou décision d'un propriétaire) ; la **Projection** (dérivation déterministe — se lit, ne se possède pas) ; le **Langage publié** ; le **Commanditaire** ; le **Détenteur du NON** ; le **Pont** (l'acte d'une personne au-dessus d'un mur) ; le **Mur** (Separate Ways) ; le **Gardien de registre** et sa **Police** ; la **Frontière de traduction** (ACL).

*(Définitions constitutionnelles formelles de ces termes : voir F2.9 Titre V — chapitre [06-architecture-constitution.md](06-architecture-constitution.md).)*

## A.3 Lexique officiel par domaine

| Domaine | Termes officiels (un sens chacun) | Interdits & faux amis détruits |
|---|---|---|
| **Engagement** | la Demande d'accord · l'Acceptation · le Refus de demande · la Caducité · l'Accord · le Créneau · la Confirmation · la Replanification · l'Annulation (toujours avec son Auteur) · l'Échéance / échu | *booking* ; « réservation » ne désigne que **le parcours vécu** (P9.2), jamais le fait — le fait est l'Accord ; « rendez-vous manqué » est une projection (No-show) |
| **Consultation** | la Rencontre · la Préparation · l'Ouverture · le Live · la Clôture · l'Interruption · l'Artefact (note, document, mémoire, résumé adopté) · le Brief · la Suite (ouverte / traitée) | *meeting, call, visio* ; **« session » est réservé à Identity & Access** — le mot legacy « session de consultation » est banni ; « le résumé de l'IA » n'existe pas : il y a la Proposition, puis l'Artefact adopté |
| **Professional Identity** | la Déclaration · la Présentation · l'Offre · l'Expertise revendiquée · l'Expérience · le Portfolio · la Masterclass · la Spécialité · le Référentiel des spécialités | *profil* nu (le « Profil assemblé » est une projection, § Réputation) ; *CV, bio* ; « expertise » nue — toujours **revendiquée** ici, **prouvée** en face |
| **Reputation** | la Preuve · l'Avis (contenu de son Auteur) · la Réponse (de l'expert, annexée) · la Certification vérifiée · la Réalisation · l'Audience mesurée · le Signalement d'avis · le Verdict · le Signal de confiance (**projection**, toujours dépliable) | *note, score, rating, étoiles, classement* (RT-03 : jamais une note fabriquée) ; « modifier un avis » n'existe pas ; « supprimer » n'existe pas — il y a le Verdict |
| **Expert Economy** | le Revenu reconnu · l'Ajustement · l'En-attente · le Disponible · le Retrait (demandé / abouti / échoué) · l'Objectif · l'Opportunité · la Prévision (**projection citée**) | *wallet, solde, gains, cashout* ; « paiement » nu — l'Encaissement est un compte rendu traduit, le Revenu est un sens, le Règlement un transport |
| **Augmentation** | la Proposition · la Production délivrée · le Marquage IA · l'Incertitude déclarée · la Citation · la Sollicitation (par une personne) · l'Adoption (acte de personne, fait chez l'adoptant) | « l'IA a décidé / a répondu / a validé » — **crimes de langage** (AE) ; *résultat IA, automatique* ; « validation » sans personne |
| **Account & Preferences** | la Personne · le Titulaire · la Préférence · la Joignabilité · le Cadre de disponibilité · l'Abonnement · l'Espace de travail (contexte) · l'Appareil · la Demande d'aide · la Fermeture | *user, settings, compte-profil* ; « disponibilité » nue — **trois sens, trois mots** : le Cadre (déclaré, ici), le Créneau (convenu, Engagement), « libre » (projection calendrier) |
| **Discovery** | l'Intérêt exprimé · le Favori · la Suggestion (retenue / écartée) · la Recherche exprimée | *feed, ranking, algorithme* comme sujets de phrase ; « recommandé pour vous » = Suggestion, citée, jamais un fait |
| **Enterprise** | l'Organisation · le Membre · l'Invitation (émise / acceptée / déclinée) · l'Appartenance · le Parrainage · la Vérification d'organisation | *employé* (→ Membre), *compte entreprise* (une Organisation n'est pas un compte), *B2B* dans le métier |
| **Consent** | le Consentement · Accordé / Refusé / Retiré / Expiré / Invalidé · la Portée · l'Accordant · le Sujet · le Gardien | **« consentement implicite » : interdit à jamais** ; *opt-in/opt-out* ; « accepter les conditions » (un contrat n'est pas un consentement) |
| **Messaging** | la Conversation · le Message · l'Interlocuteur · l'Ouverture (par une personne) · la Clôture | *chat, DM, thread, inbox* ; « le système vous a envoyé un message » — le système émet des **Signaux**, jamais des Messages |
| **Identity & Access** | la Preuve d'entrée · le Facteur · la **Session** (réservé) · la Révocation · l'Entrée | *login, password* (affaires du vestibule), *auth* ; « connecté » n'est jamais un fait métier |
| **Settlement** | l'Ordre · l'Exécution · le Compte rendu · le Canal | *paiement* nu, *transaction* nue, noms d'opérateurs dans le métier |
| **Notification** | le Signal · la Livraison · l'Émetteur · le Canal de joignabilité | *push, email, SMS* dans le métier (configuration) ; « notification lue » (état de surface) ; ne jamais confondre le **Signal** (livré) et le **Signal de confiance** (projection de Réputation) — le mot nu appartient à la Notification |

**Faux amis officiels, tranchés** : *Confirmé* (un Accord ferme) ≠ *Vérifié* (une Preuve) ≠ *Adopté* (une Proposition devenue Artefact) ≠ *Prouvé* (une Entrée). *Refus de demande* (Engagement) ≠ *Refusé* (Consent) ≠ *Décliné* (Invitation) ≠ *Écarté* (Suggestion) — quatre refus, quatre détenteurs, quatre mots.

---

# Partie B — F2.4 Domain Responsibilities

> Annexée à la Constitution **avec force constitutionnelle** (F2.9 Titre II).

Les droits et devoirs **communs à tous** : publier ses faits dans son langage ; refuser tout ce qui viole son contrat (fail closed) ; ne jamais ouvrir son intérieur ; ne jamais écrire chez autrui ; tenir ses projections pour des lectures ; répondre de sa police s'il est gardien de registre.

| Domaine | Possède | Protège | Refuse | Décide | Ne décidera JAMAIS | Invariants garantis |
|---|---|---|---|---|---|---|
| **Engagement** | la vie de l'Accord | la parole donnée des deux parties | demande incomplète, créneau hors Cadre, confirmation sans conditions accomplies, annulation hors règles | acceptation applicable, caducité, échéance | le déroulement de la Rencontre ; le prix comme sens | un Accord confirmé ne fut jamais affiché autrement ; toute Annulation porte son Auteur |
| **Consultation** | ce qui se passe et naît dans la Rencontre | la parole de la Rencontre et ses Artefacts | ouverture sans Accord échu ; enregistrement sans Consentements actifs de tous ; artefact anonyme | ouverture, clôture, interruption, suite traitée | la valeur (argent), la preuve (confiance), l'accord | le privé ne traverse jamais ; rien ne se joue « pour la note » |
| **Professional Identity** | la Déclaration et le Référentiel des spécialités | la parole de l'expert | écriture par autrui ; déclaration hors Référentiel ; preuve déguisée en déclaration | publication/retrait d'Offre ; évolution du Référentiel (acte de gouvernance) | la vérité d'une preuve | seule la personne écrit sa parole |
| **Reputation** | la Preuve et sa Police | l'intégrité de la preuve | écriture par le Sujet ; masquage sélectif ; réordonnancement flatteur | Verdict d'un Signalement ; admission d'une preuve | la déclaration ; le prix ; le classement | tout Signal de confiance se déplie vers ses preuves ; un Avis reste à son Auteur |
| **Expert Economy** | le sens de l'argent de l'expert | le revenu gagné | reconnaissance sans fait générateur ; retrait au-delà du Disponible | reconnaissance, ajustement, disponibilité | le transport ; la confiance | jamais un revenu sans Rencontre servie ; l'acquis toujours séparé du prévisionnel (BV-04) |
| **Augmentation** | les Productions et leur cage | l'éthique AE | production sans Consentement ; proposition non marquée, non citée, incertitude tue | produire, délivrer | **tout le reste — elle ne décide rien** | toute Production est Proposition, marquée, citée |
| **Account** | la Personne et ses choix | l'intimité de la personne | métier dans le Compte ; écriture par autrui | préférences applicables, fermeture | tout ce qui est métier | le Cadre n'est jamais un engagement |
| **Discovery** | l'Intérêt du client | le droit de ne plus voir | ré-proposition d'une Suggestion écartée | rétention/écart d'une Suggestion (acte du client constaté) | la pertinence comme vérité (elle reflète, ne classe pas) | un écart est mémorisé et opposable |
| **Enterprise** | le lien Organisation↔Membres | le double NON | appartenance sans acceptation du Membre | émission/révocation (chaque partie la sienne) | la vie des comptes des personnes | aucune appartenance imposée |
| **Consent** | les cinq faits et leur preuve | le NON de la personne | acte sans accord actif ; réécriture ; réouverture d'un refus définitif | validité, expiration, invalidation motivée | le contenu des actes bornés | l'histoire est immuable ; l'absence vaut non |
| **Messaging** | les Conversations | le lien et son contenu | ouverture par un domaine ; contenu dans un fait publié | clôture applicable | le passage vers la Rencontre (parcours de la personne) | seule une personne ouvre ; le contenu ne sort jamais |
| **Identity & Access** | la Preuve d'entrée | la porte | entrée sans preuve ; facteur révoqué | établissement/révocation de preuve | qui la personne *est* dans Mentora | « connecté » ne devient jamais un fait métier |
| **Settlement** | l'Exécution des Ordres | la fidélité du transport | ordre malformé ; compte rendu à un tiers | exécution/échec technique | le sens de tout montant | le compte rendu au seul Commanditaire |
| **Notification** | la Livraison des Signaux | la joignabilité voulue | signal vers une personne injoignable par ce canal ; lecture d'une vérité émettrice | livrable/non livrable | signaler (jamais) | il livre ce qu'on lui remet, à qui veut l'entendre |
| **Storage** | la Garde des Dépôts | l'intégrité et la rétention | restitution à un non-Déposant ; destruction avant rétention | conservation, destruction à l'échéance | le sens des dépôts | rien ne se perd, rien ne se lit |

**Acteurs** (uniques par rôle) : le Client, l'Expert, le Membre, l'Organisation, le Titulaire, l'Accordant, le Sujet, l'Auteur (d'un Avis, d'une Annulation), l'Interlocuteur, le Commanditaire, le Gardien. Chaque responsabilité ci-dessus est exclusive — le tableau ne contient aucune cellule partagée, et c'est vérifiable ligne à ligne.

---

# Partie C — F2.5 Public Contracts

> Annexée à la Constitution **avec force constitutionnelle** (F2.9 Titre II).

Grammaire commune des contrats : **Faits publiés** (le passé, immuable) · **Décisions publiées** (les refus rendus, motivés) · **Politiques publiées** (les règles qu'autrui doit connaître d'avance) · **Requêtes publiées** (projections offertes à la lecture) · **Commandes publiées** (ce qu'on peut demander — **toute commande est refusable par son propriétaire**) · **Capacités** (ce que le domaine sait faire pour ses commanditaires). Est **privé** : tout intérieur, toute règle en délibéré. N'est **jamais exposé** : le contenu (messages, rencontres, dépôts), les secrets d'entrée, les comptes rendus d'autrui, la matière des consentements.

| Domaine | Faits publiés | Commandes (refusables) | Requêtes (projections) | Politiques publiées | Jamais exposé |
|---|---|---|---|---|---|
| **Engagement** | Demandé, Accepté, Refusé, Caduque, Confirmé, Replanifié, Annulé (avec Auteur), Échu | demander, accepter, refuser, replanifier, annuler | état d'un Accord ; « honoré » ; No-show | règles d'annulation et de replanification, délais de caducité | les délibérations d'acceptation |
| **Consultation** | Préparée, Ouverte, Clôturée, Interrompue, ArtefactRemis (nature), SuiteOuverte, SuiteTraitée | ouvrir (si échu), clôturer, déposer un Artefact, traiter une Suite | état de la Rencontre ; ses Artefacts (natures) | règles de combinaison des Consentements de rencontre | **le contenu de la Rencontre** |
| **Professional Identity** | OffrePubliée/Retirée, ExpertiseDéclarée, ExpérienceDéclarée, PortfolioMisÀJour, ContenuDeMasterclassPublié | déclarer, publier, retirer (le Titulaire seul) | l'Offre courante ; le Référentiel des spécialités | ce qui est déclarable (Référentiel) | les brouillons de la parole |
| **Reputation** | AvisPublié, RéponsePubliée, CertificationVérifiée, RéalisationConstatée, AvisSignalé, SignalementTranché | publier un Avis (l'Auteur), répondre (l'Expert), signaler | le Profil assemblé ; les Signaux de confiance (dépliables) | RN-02/RT-03 : intangibilité, dépliabilité | l'identité d'un signaleur ; les délibérés de Verdict |
| **Expert Economy** | RevenuReconnu, RevenuAjusté, RetraitDemandé/Abouti/Échoué, ObjectifDéclaré | demander un Retrait, déclarer un Objectif | Disponible, En-attente, Historique, Prévision (citée) | règles de reconnaissance et de disponibilité | les paramètres internes des règles |
| **Augmentation** | ProductionDélivrée (marquée, citée, incertitude) | solliciter une Production (une personne, sous Consentement) | — (une proposition ne se requête pas comme vérité) | AE-01→06 (la cage, publiée) | la mécanique des modèles ; toute matière consommée |
| **Account** | PersonneEnregistrée, CompteFermé, PréférenceModifiée, JoignabilitéModifiée, CadreModifié, AbonnementSouscrit/Résilié | modifier ses choix, fermer (le Titulaire seul) | identifiants publiés ; Joignabilité ; le Cadre | ce qu'est une préférence vs un consentement | coordonnées au-delà des identifiants publiés |
| **Discovery** | FavoriAjouté/Retiré, IntérêtExprimé, SuggestionRetenue/Écartée | retenir, écarter, exprimer (le Client seul) | les Favoris ; les écarts opposables | « écarté = plus jamais proposé sans acte nouveau » | la matière des mécanismes de pertinence |
| **Enterprise** | OrganisationCréée, InvitationÉmise/Acceptée/Déclinée, AppartenanceRévoquée (avec Auteur), ParrainageAccordé/Retiré, VérificationÉtablie | inviter, accepter, décliner, révoquer, parrainer | appartenances et parrainages en cours | le double NON | la vie interne des organisations |
| **Consent** | Granted, Refused, Withdrawn, Expired, Invalidated | accorder, refuser, retirer (l'Accordant seul) | validité d'un accord pour un acte donné | fail closed ; définitivité par type ; immuabilité | la matière des actes bornés |
| **Messaging** | ConversationOuverte, MessageDéposé (sans contenu), ConversationClôturée | ouvrir, déposer, clore (un Interlocuteur) | ses conversations (au seul Interlocuteur) | seule une personne ouvre | **le contenu, à jamais** |
| **Identity & Access** | PreuveÉtablie, PreuveRévoquée | (via ACL du Compte) établir, révoquer | — | exigences de preuve | les secrets, les facteurs |
| **Settlement** | OrdreExécuté/Échoué (au Commanditaire) | ordonner (Commanditaires via ACL) | — | contrat de service neutre | les dialectes d'opérateurs |
| **Notification** | SignalLivré/NonLivrable (à l'Émetteur) | remettre un Signal | — | respect de la Joignabilité | le contenu des signaux d'autrui |
| **Storage** | DépôtConservé/Restitué/Détruit (au Déposant) | déposer, restituer, détruire-à-échéance | — | rétention portée par l'ordre | le contenu des dépôts |

---

# Lois ajoutées par ce chapitre (10 → 13)

S'ajoutant aux neuf lois de F2.2 (consolidées en 18 par F2.9) :

10. **Un mot nu ambigu est interdit** — la qualification est obligatoire aux frontières.
11. **Le langage ignore les écrans et la technique** — aucun nom de surface ni d'outil dans le métier.
12. **Toute commande est refusable par son propriétaire** — l'irréfusable est une écriture déguisée.
13. **Les mots du legacy ne traversent que traduits** — l'ACL est aussi linguistique.

**Règle des commandes** : toute commande publiée est refusable ; une commande irréfusable serait une écriture chez autrui — aucune n'existe.

---

## Provenance de matérialisation (non normatif)

Reconstruction fidèle de l'état final ratifié à partir des sources de session :

- **Chapitre combiné F2.3 + F2.4 + F2.5** — langage (lois transversales, vocabulaire, lexique par domaine, faux amis), responsabilités (charte par domaine, acteurs), contrats publics (grammaire, table par domaine), lois 10-13. **Renommage officiel** ratifié dans ce chapitre : le générique de livraison est **Notification** (mort de l'ambiguïté « Signalement », qui appartient désormais à la seule Réputation).
- **F2.9** — ratifie ce chapitre sans l'amender (« aucun domaine créé, supprimé, déplacé, fusionné, scindé ou renommé ») et **annexe** F2.4 et F2.5 à la Constitution **avec force constitutionnelle** (Titre II).

**Divergence résolue par propriété** : la source du chapitre combiné écrivait, dans la table des contrats (Réputation), le fait « VerditTranché ». Le nom d'événement appartient à **F2.2** (propriétaire des événements), qui l'a gelé sous la forme **`SignalementTranché`** (F2.2.99, police du registre de Réputation). Le nom a été réconcilié au propriétaire (`SignalementTranché`) ; la variante de la source est signalée ici, sans autre modification.

Non dupliqués ici : les **définitions constitutionnelles formelles** des termes transversaux (F2.9 Titre V — chapitre [06-architecture-constitution.md](06-architecture-constitution.md)) et la **correspondance bilingue FR↔EN** (Dictionnaire — chapitre [04-bilingual-dictionary.md](04-bilingual-dictionary.md)). Le scaffolding de session (Phase 0, audit-processus, risques, décision, État Git, STOP) n'est pas reproduit.
