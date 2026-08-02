# REPUTATION PLATFORM FOUNDATION

**Statut** : Référence officielle — aucun développement concernant la Reputation Platform ne sera réalisé en dehors de cette architecture.
**Portée** : Architecture fonctionnelle uniquement. Aucun écran, aucun widget, aucune maquette, aucun pixel, aucun code, aucun pseudo-code, aucune logique métier, aucun provider, aucune persistance.
**Filiation** : ce document réalise la « Reputation Platform » du §3.4 de [MENTORA EXPERT PLATFORM V2](mentora-expert-platform-v2.md) et alimente le Home défini par [HOME PLATFORM FOUNDATION](home-platform-foundation.md), aux côtés des fondations [Consultation](consultation-platform-foundation.md), [Business](business-platform-foundation.md) et [AI](ai-platform-foundation.md). En cas de conflit, P9.0 prévaut.

---

## 1. Mission

La Reputation Platform n'est **pas un profil utilisateur**. Elle n'est **pas une page publique**. Elle n'est **pas un réseau social**.

Elle représente la **confiance professionnelle de l'expert**. Elle explique **pourquoi un client peut lui faire confiance**.

**Mission en une phrase** : représenter professionnellement l'identité et la crédibilité de l'expert — à partir de preuves, jamais de déclarations.

Elle ne possède jamais : les consultations, les paiements, les paramètres, les messages, les décisions IA, les plateformes système. Elle représente uniquement la réputation professionnelle.

---

## 2. Vision

| Règle | Énoncé |
|---|---|
| RV-01 | La réputation **se construit**. Elle ne se déclare jamais. |
| RV-02 | Elle est le **résultat d'un parcours professionnel** : consultations servies, avis reçus, preuves apportées, savoir partagé. |
| RV-03 | La plateforme **représente** cette confiance. Elle ne la fabrique jamais. |
| RV-04 | Tout ce qui s'affiche a une provenance ; ce qui n'est pas prouvé s'affiche non prouvé (fail closed — cohérent avec FR-05 de P9.0). |

---

## 3. Les domaines métier

Onze domaines fonctionnels. Chaque information de réputation appartient à exactement un domaine.

### 3.1 Professional Identity

| | |
|---|---|
| **Mission** | Dire qui est l'expert, professionnellement. |
| **Responsabilités** | Représenter l'identité de métier : nom professionnel, spécialité principale, présentation. |
| **Frontières** | L'identité de compte (authentification, coordonnées) appartient à l'Account Platform. L'identité professionnelle dit le métier, jamais le compte. |
| **Propriétaire** | Reputation Platform. |
| **Informations publiées** | Profil à compléter (identité incomplète). |

### 3.2 Public Profile

| | |
|---|---|
| **Mission** | Assembler ce que le monde voit — la vitrine fidèle du parcours. |
| **Responsabilités** | Représenter la composition publique : ce qui est visible, dans quel ordre ; refléter l'état de complétude. |
| **Frontières** | Le profil **assemble** des faits possédés par les autres domaines ; il n'en crée aucun. Sa diffusion dans la recherche appartient au système Search. |
| **Propriétaire** | Reputation Platform. |
| **Informations publiées** | Profil à compléter ; profil renforcé. |

### 3.3 Expertise

| | |
|---|---|
| **Mission** | Dire ce que l'expert sait faire — et le prouver. |
| **Responsabilités** | Représenter les domaines de compétence, leur niveau, leurs preuves d'appui (certifications, réalisations, avis liés). |
| **Frontières** | Une expertise sans preuve se présente comme déclarée, jamais comme vérifiée (RT-06). La pertinence d'une expertise pour un client appartient au système Recommendation. |
| **Propriétaire** | Reputation Platform. |
| **Informations publiées** | Nouvelle expertise (une fois étayée). |

### 3.4 Certifications

| | |
|---|---|
| **Mission** | Porter les preuves formelles : diplômes, validations, accréditations. |
| **Responsabilités** | Représenter chaque certification, son émetteur, sa validité, son échéance ; conduire au renouvellement. |
| **Frontières** | La vérité d'une certification appartient à son émetteur ; la plateforme la représente vérifiée ou non vérifiée, jamais davantage (RT-07). |
| **Propriétaire** | Reputation Platform (représentation) ; émetteurs (preuve). |
| **Informations publiées** | Nouvelle certification ; certification arrivant à échéance (Attention). |

### 3.5 Experience

| | |
|---|---|
| **Mission** | Raconter le parcours : ce que l'expert a fait, où, depuis quand. |
| **Responsabilités** | Représenter l'expérience professionnelle déclarée et l'expérience prouvée sur Mentora (ancienneté, volume servi). |
| **Frontières** | Les faits d'activité (consultations servies) appartiennent à la Consultation Platform — cités, jamais recomptés. Le déclaré et le prouvé ne se mélangent jamais (RT-04). |
| **Propriétaire** | Reputation Platform. |
| **Informations publiées** | — (domaine de consultation, aucune remontée Home). |

### 3.6 Reviews

| | |
|---|---|
| **Mission** | Porter la voix des clients — intacte. |
| **Responsabilités** | Représenter les avis reçus, leur ensemble, les réponses de l'expert ; conduire à la réponse. |
| **Frontières** | Un avis appartient à son auteur : jamais modifié, jamais masqué sélectivement, jamais réordonné pour flatter (RN-02, RT-03). La réponse appartient à l'expert ; l'aide à la réponse est une proposition de l'AI Platform, citée. |
| **Propriétaire** | Reputation Platform (représentation) ; auteurs (contenu). |
| **Informations publiées** | Nouvel avis reçu ; avis en attente de réponse (Attention). |

### 3.7 Achievements

| | |
|---|---|
| **Mission** | Reconnaître les caps francs du parcours. |
| **Responsabilités** | Représenter les réalisations et badges obtenus (jalons servis, régularité, excellence), leurs critères, leur date. |
| **Frontières** | Un badge se **gagne** selon des critères publiés par la plateforme Mentora ; il ne s'achète jamais (RT-02), ne se déclare jamais. |
| **Propriétaire** | Reputation Platform. |
| **Informations publiées** | Nouveau badge ; nouvelle réalisation. |

### 3.8 Masterclass

| | |
|---|---|
| **Mission** | Porter le savoir enseigné par l'expert — son autorité en actes. |
| **Responsabilités** | Représenter les Masterclass de l'expert, leur état (préparée, publiée), leur audience. |
| **Frontières** | Le revenu des Masterclass est lu par la Business Platform (le fait générateur reste ici — BEX-04 de P9.3) ; la diffusion appartient aux mécanismes de contenu. |
| **Propriétaire** | Reputation Platform. |
| **Informations publiées** | Masterclass publiée. |

### 3.9 Portfolio

| | |
|---|---|
| **Mission** | Montrer les travaux qui parlent d'eux-mêmes. |
| **Responsabilités** | Représenter les contenus professionnels choisis par l'expert : études de cas, publications, conférences, livres. |
| **Frontières** | L'expert choisit ce qu'il expose ; la plateforme distingue toujours l'auto-présenté du vérifié (RT-04). Rien de privé n'entre jamais au Portfolio (invariant Mentora : le privé ne traverse pas). |
| **Propriétaire** | Reputation Platform. |
| **Informations publiées** | — (domaine de vitrine, aucune remontée Home). |

### 3.10 Audience

| | |
|---|---|
| **Mission** | Dire qui écoute l'expert — portée, visibilité, communauté. |
| **Responsabilités** | Représenter l'audience (vues du profil, suivis, portée des Masterclass) et sa dynamique. |
| **Frontières** | Les faits d'audience viennent des mécanismes de mesure ; leur lecture des causes appartient à l'AI Platform (insight, cité). L'audience n'est jamais un score de valeur professionnelle — elle mesure la portée, pas la compétence. |
| **Propriétaire** | Reputation Platform. |
| **Informations publiées** | Progression importante. |

### 3.11 Trust Signals

| | |
|---|---|
| **Mission** | Condenser la confiance en signaux immédiatement lisibles — pourquoi ce client peut me faire confiance, en un regard. |
| **Responsabilités** | Représenter les signaux agrégés (vérifié, expérimenté, bien évalué, certifié, régulier), chacun adossé à ses preuves consultables. |
| **Frontières** | Un signal est une **synthèse de preuves existantes** — jamais une note fabriquée, jamais un classement d'experts entre eux. Chaque signal se déplie vers ses preuves (RT-03). |
| **Propriétaire** | Reputation Platform. |
| **Informations publiées** | — (les signaux vivent au profil ; leurs progrès remontent via §7). |

---

## 4. Responsabilités

### 4.1 Autorisées

| Règle | La Reputation Platform PEUT |
|---|---|
| RP-01 | Représenter l'identité professionnelle. |
| RP-02 | Représenter les compétences. |
| RP-03 | Représenter les certifications. |
| RP-04 | Représenter les avis. |
| RP-05 | Représenter les réalisations. |
| RP-06 | Représenter la progression. |
| RP-07 | Représenter les contenus professionnels. |
| RP-08 | Publier les indicateurs de confiance (§7). |

### 4.2 Interdites

| Règle | La Reputation Platform NE PEUT JAMAIS |
|---|---|
| RN-01 | Décider de la réputation — elle la représente, les faits la construisent. |
| RN-02 | Modifier un avis. |
| RN-03 | Créer une consultation — Consultation Platform. |
| RN-04 | Réaliser un paiement — mécanismes financiers. |
| RN-05 | Recommander un expert — système Recommendation (via l'AI Platform). |
| RN-06 | Posséder les messages — Account Platform. |
| RN-07 | Posséder les paramètres — Account Platform. |
| RN-08 | Posséder les plateformes système. |
| RN-09 | Connaître les moteurs IA. |
| RN-10 | Connaître les providers — aucun vendor, aucun mécanisme, aucun nom technique (FR-06 de P9.0). |

---

## 5. Relation avec les plateformes

### 5.1 Plateformes métier

| Plateforme | Relation | Frontière |
|---|---|---|
| Home Platform | reçoit les remontées du §7 | le Home ne possède jamais la réputation |
| Consultation Platform | fournit les faits d'activité (consultations servies) qui étayent Experience et Achievements ; la fidélisation nourrit les avis | les faits restent à la Consultation, cités ici |
| Business Platform | lit le revenu des Masterclass (fait générateur ici, lecture là-bas — BEX-04) | la frontière ne se déplace jamais avec l'argent |
| AI Platform | propose : aide à la réponse aux avis, lectures d'audience, suggestions de renforcement du profil — toutes citées, refusables | l'IA propose, la réputation n'exécute jamais une proposition d'elle-même |
| Account Platform | possède l'identité de compte, les notifications, la sécurité | l'identité professionnelle ici, l'identité de compte là-bas |

### 5.2 Plateformes système

| Plateforme système | Ce qu'elle possède | Ce que la Reputation Platform en fait |
|---|---|---|
| Recommendation | la mise en relation pertinente | est lue par elle ; ne la pilote jamais (RN-05) |
| Summary | la production des résumés | aucun lien direct — les résumés restent au cycle de consultation |
| Memory | la mémoire mécanique | aucun contenu de réputation n'y transite hors invariants de confidentialité |
| Gateway | l'accès unique aux capacités IA | jamais contacté — toute capacité IA arrive par l'AI Platform |
| Search | la découvrabilité | consomme le profil public ; la plateforme ne classe jamais |
| Session / Experience | la Salle Live | aucun lien direct — la réputation ne vit pas en séance |

| Règle | Énoncé |
|---|---|
| RS-01 | Chaque plateforme reste propriétaire de sa logique ; la Reputation Platform représente uniquement la confiance professionnelle. |
| RS-02 | Aucun nom technique dans l'expérience (UX-10). |
| RS-03 | Une source de preuve indisponible dégrade localement le domaine concerné — le signal correspondant se présente non vérifiable, jamais supposé (fail closed). |
| RS-04 | Tout nouveau flux de preuve s'intègre par un domaine existant (§3) ; sinon, c'est ce document qu'on révise. |

---

## 6. Les moments de réputation

La plateforme est organisée autour des **moments de l'évolution professionnelle**. Jamais des états techniques.

| Moment | Ce que vit l'expert | Ce qui domine |
|---|---|---|
| **Premier avis** | « Un client a parlé de moi » | la reconnaissance du premier retour ; l'invitation à répondre |
| **Nouvel avis** | « Qu'a-t-il dit ? » | l'avis intact ; la réponse en un geste |
| **Certification obtenue** | « C'est validé » | la preuve ajoutée au profil ; sa visibilité |
| **Nouveau badge** | « Cap franchi » | le critère atteint, daté, consultable |
| **Nouvelle expertise** | « Je le fais savoir » | l'expertise et son état (déclarée / étayée) |
| **Nouvelle masterclass** | « Je transmets » | la publication et son audience naissante |
| **Nouvelle réalisation** | « J'ai accompli » | la réalisation au Portfolio ou aux Achievements |
| **Profil renforcé** | « Ma vitrine progresse » | ce qui a changé et ce que ça apporte |
| **Objectif réputation atteint** | « J'y suis » | la reconnaissance du fait ; le prochain cap possible (proposé par l'IA, cité) |
| **Aucune nouveauté** | « Rien de neuf » | le calme assumé ; jamais de contenu de remplissage (EV-04 du Home) |

| Règle | Énoncé |
|---|---|
| RMO-01 | Un moment de réputation est un fait daté et sourcé — jamais un jugement d'interface. |
| RMO-02 | Le moment détermine ce qui remonte en tête et l'action principale unique (MF-07). |
| RMO-03 | Aucun moment ne compare l'expert à d'autres experts : la réputation se construit contre son propre parcours, jamais en classement. |
| RMO-04 | Tout nouveau moment s'ajoute par révision de ce document, jamais par cas particulier d'implémentation. |

---

## 7. Les informations publiées vers le Home

La Reputation Platform est le **propriétaire exclusif** de ces remontées. Aucune autre plateforme ne pourra jamais les publier.

| Remontée | Contenu | Famille Home (§4 Home Foundation) |
|---|---|---|
| **Nouvel avis reçu** | un avis vient d'arriver (et l'invitation à répondre) | Attention |
| **Nouvelle certification** | une preuve formelle ajoutée | Progression |
| **Nouveau badge** | un cap reconnu | Progression |
| **Nouvelle réalisation** | un accomplissement ajouté | Progression |
| **Profil à compléter** | un manque qui affaiblit la confiance | Attention |
| **Masterclass publiée** | un contenu d'autorité en ligne | Progression |
| **Progression importante** | une dynamique d'audience ou de confiance notable | Progression |

*Note* : « certification arrivant à échéance » et « avis en attente de réponse » remontent dans la famille Attention (déjà prévues au §5 de la Home Foundation).

| Règle | Énoncé |
|---|---|
| RPU-01 | Toute remontée est un fait daté et sourcé — jamais une interprétation locale. |
| RPU-02 | La plateforme retire elle-même ses remontées devenues sans objet (DIS-02 du Home). |
| RPU-03 | Une preuve indisponible ne publie rien — jamais une remontée supposée (IND-02 du Home). |
| RPU-04 | Toute nouvelle remontée s'ajoute par révision conjointe de ce document et de la Home Foundation. |

---

## 8. Mobile First

La plateforme respecte **intégralement** les règles MF-01 → MF-10 de P9.0. En particulier :

| Règle | Application |
|---|---|
| RMF-01 | Une main : répondre à un avis, compléter le profil, renouveler une certification — l'action vit dans la zone du pouce. |
| RMF-02 | Lecture verticale : la confiance d'abord (Trust Signals), les preuves ensuite, le détail en dernier. |
| RMF-03 | Une action principale par surface (MF-07). |
| RMF-04 | Aucune surcharge : jamais plus de six éléments d'attention (UX-07). |
| RMF-05 | Comprises en moins de cinq secondes (UX-01) : la question « pourquoi me faire confiance » a sa réponse immédiate. |
| RMF-06 | **La confiance est lisible immédiatement** : les Trust Signals ouvrent la lecture ; tout signal se déplie vers ses preuves en un geste. |

---

## 9. Principes de confiance

| Règle | La réputation |
|---|---|
| RT-01 | **se construit** : elle résulte de faits, jamais d'un réglage. |
| RT-02 | **ne s'achète jamais** : aucun signal, badge ou mise en avant contre paiement. |
| RT-03 | **reste transparente** : toute affirmation se déplie vers sa preuve. |
| RT-04 | **distingue toujours les faits des interprétations** : le vérifié, le déclaré et le proposé (IA) ne se mélangent jamais. |
| RT-05 | **respecte toujours les preuves** : une preuve se cite intacte ; elle ne s'embellit pas. |
| RT-06 | **n'invente jamais une compétence** : sans preuve, une expertise est déclarée — et se présente comme telle. |
| RT-07 | **n'invente jamais une certification** : non vérifiée signifie non vérifiée, visiblement. |
| RT-08 | **ne masque jamais un manque d'information** : l'absence se dit ; elle ne se comble jamais (fail closed). |

Ces principes sont **perpétuels** : aucune extension (§11) ne peut les affaiblir.

---

## 10. Gouvernance

| Règle | Énoncé |
|---|---|
| RG-01 | Une information de réputation possède toujours une **source**. |
| RG-02 | Une preuve possède toujours un **propriétaire** (auteur d'avis, émetteur de certification, plateforme pour les faits d'activité). |
| RG-03 | Les plateformes système restent invisibles. |
| RG-04 | La réputation ne déplace jamais une responsabilité métier : représenter n'est pas posséder. |
| RG-05 | Les moteurs restent invisibles. Les providers restent invisibles. |
| RG-06 | Ces règles ont vocation à devenir des **règles exécutables** (balayages de gouvernance) dès la première vague d'implémentation — même discipline que le reste de l'architecture Enterprise. |

---

## 11. Extensibilité — pensé pour dix ans

| Extension | Comment elle s'insère |
|---|---|
| Nouvelles certifications | le domaine Certifications, un émetteur de plus |
| Nouveaux badges, nouveaux niveaux | le domaine Achievements, des critères publiés de plus |
| Nouvelles expertises | le domaine Expertise |
| Nouveaux contenus, formations, masterclass | les domaines Masterclass et Portfolio |
| Publications, conférences, livres | le domaine Portfolio |
| Distinctions | le domaine Achievements |
| Partenaires, organisations professionnelles | des émetteurs de preuves de plus (Certifications) et des contextes d'appartenance (Identity) |
| Nouveaux signaux de confiance | le domaine Trust Signals — toujours des synthèses de preuves, jamais des notes fabriquées |

| Règle | Énoncé |
|---|---|
| REX-01 | Les onze domaines (§3) sont l'invariant décennal : les extensions les enrichissent ; en ajouter ou en retirer exige une révision de ce document. |
| REX-02 | Toute extension nomme son domaine d'attache et le propriétaire de sa preuve avant tout développement. |
| REX-03 | Aucune extension ne peut réintroduire une possession interdite (RN-01 → RN-10) ni affaiblir un principe de confiance (RT-01 → RT-08). |
| REX-04 | Tout nouveau signal de confiance naît de preuves existantes ou de nouvelles preuves sourcées — jamais d'un calcul opaque. |

---

## 12. Gouvernance du document

- Ce document est la **référence officielle** de la Reputation Platform. Aucun développement la concernant en dehors.
- Toute vague d'implémentation cite le domaine, le moment et les règles (RV/RP/RN/RS/RMO/RPU/RMF/RT/RG/REX) qu'elle réalise.
- Toute modification de ce document est une décision d'architecture explicite, tracée, jamais un effet de bord d'une vague d'implémentation.
- En cas de conflit avec [MENTORA EXPERT PLATFORM V2](mentora-expert-platform-v2.md), P9.0 prévaut ; les remontées se révisent conjointement avec la [HOME PLATFORM FOUNDATION](home-platform-foundation.md) (RPU-04).
