# BUSINESS PLATFORM FOUNDATION

**Statut** : Référence officielle — aucun développement concernant la Business Platform ne sera réalisé en dehors de cette architecture.
**Portée** : Architecture fonctionnelle uniquement. Aucun écran, aucun widget, aucune maquette, aucun pixel, aucun code, aucun pseudo-code, aucune logique métier, aucun provider, aucune persistance.
**Filiation** : ce document réalise la « Business Platform » du §3.1 de [MENTORA EXPERT PLATFORM V2](mentora-expert-platform-v2.md) et alimente le Home défini par [HOME PLATFORM FOUNDATION](home-platform-foundation.md), aux côtés de [CONSULTATION PLATFORM FOUNDATION](consultation-platform-foundation.md). En cas de conflit, P9.0 prévaut.

---

## 1. Mission

La Business Platform n'est **pas un portefeuille**. Elle n'est **pas une liste de transactions**.

Elle représente la **santé économique de l'activité de l'expert**.

**Mission en une phrase** : représenter la performance économique de l'activité professionnelle de l'expert — l'expliquer, jamais se limiter à afficher des montants.

Elle ne possède jamais les consultations. Elle ne possède jamais les paiements techniques. Elle ne possède jamais la logique de facturation. Elle représente uniquement la **vision métier** de la performance économique.

Le Home ne possède jamais les informations financières : il reçoit uniquement les remontées publiées par cette plateforme (§7).

---

## 2. Vision — expliquer l'activité

Un expert ne veut pas seulement connaître son solde. Il veut **comprendre son activité**.

La plateforme répond instantanément à :

1. combien ai-je gagné **aujourd'hui** ?
2. combien vais-je **probablement** gagner ?
3. suis-je **en avance** sur mes objectifs ?
4. mon activité **progresse-t-elle** ?
5. quels revenus sont **en attente** ?
6. quelles **actions** peuvent améliorer mes résultats ?

| Règle | Énoncé |
|---|---|
| BV-01 | Chaque question a une réponse en moins de cinq secondes de lecture (UX-01 de P9.0). |
| BV-02 | Un montant ne s'affiche jamais seul : il s'affiche avec sa lecture (d'où il vient, où il va, ce qu'il signifie pour l'objectif). |
| BV-03 | Honnêteté absolue : un inconnu s'affiche inconnu — jamais un zéro à la place d'un inconnu, jamais une estimation présentée comme un fait (IND-05 du Home). |
| BV-04 | Une prévision est toujours nommée prévision, avec sa provenance ; elle n'est jamais mêlée aux faits acquis. |

---

## 3. Les domaines métier

Neuf domaines fonctionnels. Chaque information économique appartient à exactement un domaine.

### 3.1 Performance

| | |
|---|---|
| **Mission** | Donner la lecture d'ensemble : comment va mon activité, maintenant. |
| **Responsabilités** | Représenter la synthèse du jour, de la semaine, du mois ; porter la réponse « combien ai-je gagné aujourd'hui ». |
| **Frontières** | La synthèse agrège des faits publiés par les autres domaines ; elle n'invente aucun chiffre et ne recalcule rien qui appartienne aux mécanismes financiers. |
| **Propriétaire** | Business Platform. |
| **Informations publiées** | Revenus du jour ; performance exceptionnelle. |

### 3.2 Revenus

| | |
|---|---|
| **Mission** | Représenter ce que l'activité rapporte, par source et par période. |
| **Responsabilités** | Ventiler les gains (consultations, et demain Masterclass, abonnements…) ; distinguer l'acquis, l'en-attente et le prévisionnel. |
| **Frontières** | Le fait générateur (une consultation servie) appartient à la Consultation Platform ; l'encaissement technique appartient aux mécanismes Payment/Financial. Les Revenus lisent, ils n'encaissent pas. |
| **Propriétaire** | Business Platform. |
| **Informations publiées** | Revenus en attente ; nouvelle source de revenus active. |

### 3.3 Paiements

| | |
|---|---|
| **Mission** | Représenter l'état des encaissements du point de vue de l'expert. |
| **Responsabilités** | Refléter reçu / en cours / bloqué / litige, tel que publié par le mécanisme ; conduire vers la résolution quand une décision de l'expert est requise. |
| **Frontières** | Le mécanisme d'encaissement appartient à la Payment Platform (système). La Business Platform ne décide jamais d'un paiement, ne le déclenche pas, ne le reformule pas. |
| **Propriétaire** | Business Platform (lecture métier) ; Payment Platform (mécanisme). |
| **Informations publiées** | Paiement reçu ; paiement nécessitant une attention. |

### 3.4 Retraits

| | |
|---|---|
| **Mission** | Représenter la disponibilité et le devenir de l'argent de l'expert. |
| **Responsabilités** | Refléter le disponible, les demandes en cours, l'historique des retraits ; conduire vers l'action de retrait. |
| **Frontières** | Le solde et l'exécution appartiennent aux mécanismes Wallet/Financial. La Business Platform ne réalise jamais un retrait : elle conduit vers le mécanisme qui l'exécute. |
| **Propriétaire** | Business Platform (lecture métier) ; Wallet Platform (mécanisme). |
| **Informations publiées** | Retrait disponible ; retrait en attente. |

### 3.5 Objectifs

| | |
|---|---|
| **Mission** | Donner un cap : où j'en suis par rapport à ce que je vise. |
| **Responsabilités** | Représenter les objectifs de l'expert (période, cible), leur progression, leur état (en avance, au rythme, en retard, atteint). |
| **Frontières** | L'objectif appartient à l'expert : la plateforme le représente et le suit, elle ne l'impose jamais. Les suggestions d'objectifs pertinents relèvent de l'AI Platform, citées comme telles. |
| **Propriétaire** | Business Platform. |
| **Informations publiées** | Objectif mensuel (progression) ; objectif atteint ; objectif en retard. |

### 3.6 Croissance

| | |
|---|---|
| **Mission** | Dire si l'activité progresse, stagne ou recule — et le montrer honnêtement. |
| **Responsabilités** | Représenter les tendances (période sur période), les caps franchis, la dynamique. |
| **Frontières** | La tendance est un fait calculé chez sa source de vérité financière ; la lecture des causes et des leviers appartient à l'AI Platform. La Croissance montre, elle n'explique pas seule. |
| **Propriétaire** | Business Platform. |
| **Informations publiées** | Croissance ; activité en baisse. |

### 3.7 Historique financier

| | |
|---|---|
| **Mission** | Garantir que tout le passé économique est retrouvable et lisible. |
| **Responsabilités** | Représenter l'historique par période, par source, par consultation servie ; permettre la vérification sans jamais noyer. |
| **Frontières** | L'historique cite les faits des mécanismes (Payment, Wallet, Financial) et de la Consultation Platform ; il ne reconstruit rien, ne corrige rien. |
| **Propriétaire** | Business Platform (lecture) ; mécanismes financiers (faits). |
| **Informations publiées** | — (domaine de consultation, aucune remontée Home). |

### 3.8 Prévisions

| | |
|---|---|
| **Mission** | Répondre à « combien vais-je probablement gagner » — sans jamais mentir. |
| **Responsabilités** | Représenter le prévisionnel fondé sur l'engagé (consultations réservées) et le probable (tendance), toujours séparé de l'acquis (BV-04). |
| **Frontières** | Le calcul prévisionnel appartient à sa source de vérité (mécanismes financiers, intelligence de l'AI Platform) ; la Business Platform représente la prévision citée avec sa provenance. Aucune prévision inventée localement. |
| **Propriétaire** | Business Platform (représentation) ; AI Platform / mécanismes (calcul). |
| **Informations publiées** | — (le prévisionnel ne remonte pas au Home : le Home vit au présent). |

### 3.9 Opportunités

| | |
|---|---|
| **Mission** | Montrer où l'activité peut s'améliorer — la réponse à la question 6. |
| **Responsabilités** | Représenter les leviers économiques actionnables (créneaux à ouvrir, demande non servie, source à activer), conduire vers l'action chez le bon propriétaire. |
| **Frontières** | L'intelligence qui formule les opportunités appartient à l'AI Platform (elle propose, ne décide jamais) ; la Business Platform porte leur cadre économique et leur publication. Toute opportunité est citée avec sa provenance IA, refusable en un geste (UX-09). |
| **Propriétaire** | Business Platform (cadre économique) ; AI Platform (formulation). |
| **Informations publiées** | Opportunité importante. |

---

## 4. Responsabilités

### 4.1 Autorisées

| Règle | La Business Platform PEUT |
|---|---|
| BP-01 | Représenter la performance économique de l'activité. |
| BP-02 | Organiser les informations financières en domaines métier (§3). |
| BP-03 | Publier les indicateurs destinés au Home (§7) — et uniquement ceux-là. |
| BP-04 | Montrer la progression de l'activité. |
| BP-05 | Représenter les objectifs de l'expert. |
| BP-06 | Représenter les tendances. |

### 4.2 Interdites

| Règle | La Business Platform NE PEUT JAMAIS |
|---|---|
| BN-01 | Créer une consultation — cycle de vie propriété de la Consultation Platform. |
| BN-02 | Décider d'un paiement — mécanisme Payment. |
| BN-03 | Posséder la réputation — Reputation Platform. |
| BN-04 | Posséder les recommandations IA — AI Platform (elle en cite, ne les possède pas). |
| BN-05 | Posséder les paramètres — Account Platform. |
| BN-06 | Posséder les messages — Account Platform. |
| BN-07 | Réaliser un retrait — mécanisme Wallet ; elle conduit, n'exécute pas. |
| BN-08 | Calculer les commissions techniques — mécanismes financiers. |
| BN-09 | Connaître les providers financiers — aucun vendor, aucun mécanisme, aucun nom technique (FR-06 de P9.0). |

---

## 5. Dialogue avec les plateformes

Les plateformes restent **propriétaires de leur logique**. La Business Platform représente uniquement l'activité économique.

| Plateforme | Ce qu'elle possède | Ce que la Business Platform en fait |
|---|---|---|
| Consultation Platform | le cycle de vie, le fait « consultation servie » | lit le fait générateur de revenu ; ne crée ni ne modifie jamais une consultation |
| Financial Platform | l'orchestration financière, les règles de calcul | reçoit les faits calculés (montants, commissions, tendances) ; ne recalcule jamais |
| Payment Platform | l'encaissement et ses états | reflète reçu / en cours / bloqué ; ne décide ni ne déclenche jamais |
| Wallet Platform | le solde et l'exécution des retraits | reflète le disponible ; conduit vers le retrait sans l'exécuter |
| AI Platform | l'intelligence : prévisions probables, leviers, opportunités formulées | cite les lectures IA avec provenance ; ne possède jamais la recommandation |
| Home Platform | l'agrégation des remontées | reçoit les publications du §7 ; le Home ne possède jamais le financier |

| Règle | Énoncé |
|---|---|
| BS-01 | La Business Platform ne parle jamais à un provider financier, un adapter ou un vendor — elle dialogue avec des plateformes, jamais avec des mécanismes. |
| BS-02 | Aucun nom technique dans l'expérience : l'expert lit son activité, jamais l'architecture (UX-10). |
| BS-03 | Un mécanisme indisponible dégrade localement le domaine concerné — explicitement, fail closed — jamais la plateforme entière (IND-03 du Home). |
| BS-04 | Toute nouvelle source financière s'intègre par un domaine existant (§3) ; si aucun ne convient, c'est ce document qu'on révise. |

---

## 6. Les moments économiques

La plateforme est organisée autour des **moments de la vie économique** de l'expert. Jamais des états techniques.

| Moment | Ce que vit l'expert | Ce qui domine |
|---|---|---|
| **Premiers revenus** | « Ça y est, ça commence » | la reconnaissance du premier gain ; la mise en route des objectifs |
| **Croissance** | « Ça progresse » | la tendance, les caps franchis |
| **Objectif atteint** | « Je l'ai fait » | la reconnaissance du fait, publiée au Home ; le prochain cap proposé (IA, citée) |
| **Objectif en retard** | « Je dois ajuster » | la progression et les opportunités — sans culpabilisation (ton de confiance, cohérent avec le Home) |
| **Paiement reçu** | « L'argent est arrivé » | le fait, sa provenance, son effet sur le disponible |
| **Retrait disponible** | « Je peux retirer » | le disponible et la conduite vers l'action |
| **Retrait en attente** | « Où en est mon argent ? » | l'état exact de la demande, sans euphémisme |
| **Activité exceptionnelle** | « Journée remarquable » | la performance et ce qui l'explique (lecture IA, citée) |
| **Activité en baisse** | « Ça ralentit » | le fait honnête et les leviers actionnables |
| **Aucune activité** | « Rien ne rentre » | l'état assumé sans culpabilisation ; la conduite vers ce qui construit (disponibilités, réputation, opportunités) |

| Règle | Énoncé |
|---|---|
| BM-01 | Un moment économique est un fait publié par sa source de vérité — jamais un jugement d'interface. |
| BM-02 | Les moments d'exception (objectif atteint / en retard, activité exceptionnelle / en baisse) colorent la lecture ; ils ne masquent jamais les faits courants. |
| BM-03 | C'est cette plateforme qui publie les moments économiques consommés par le Home (« objectif atteint », « objectif en retard » — §11 de la Home Foundation) ; le Home applique, ne calcule pas (MO-01). |
| BM-04 | Aucun moment ne culpabilise : la plateforme explique et outille, elle ne juge jamais. |
| BM-05 | Tout nouveau moment s'ajoute par révision de ce document, jamais par cas particulier d'implémentation. |

---

## 7. Les informations publiées vers le Home

La Business Platform est le **propriétaire exclusif** de ces remontées. Aucune autre plateforme ne pourra jamais les publier.

| Remontée | Contenu | Famille Home (§4 Home Foundation) |
|---|---|---|
| **Revenus du jour** | le gain du jour et son état | Revenu du jour |
| **Objectif mensuel** | la progression vers l'objectif de la période | Progression |
| **Croissance** | la dynamique de l'activité | Progression |
| **Paiement reçu** | un encaissement notable | Revenu du jour |
| **Retrait disponible** | de l'argent prêt à être retiré | Attention |
| **Performance exceptionnelle** | une journée ou période remarquable | Progression |
| **Opportunité importante** | un levier économique actionnable (formulé par l'IA, cité) | Attention |

| Règle | Énoncé |
|---|---|
| BPU-01 | Toute remontée est un fait publié par sa source de vérité — jamais une interprétation locale. |
| BPU-02 | La plateforme retire elle-même ses remontées devenues sans objet (DIS-02 du Home). |
| BPU-03 | Une remontée indisponible est publiée indisponible — jamais estimée, jamais un zéro (IND-02, IND-05 du Home). |
| BPU-04 | Toute nouvelle remontée s'ajoute par révision conjointe de ce document et de la Home Foundation. |

---

## 8. Mobile First

La plateforme respecte **intégralement** les règles MF-01 → MF-10 de P9.0. En particulier :

| Règle | Application |
|---|---|
| BMF-01 | Une seule main : l'action principale (retirer, ajuster l'objectif, saisir l'opportunité) vit dans la zone du pouce. |
| BMF-02 | Lecture verticale : la santé économique se lit de haut en bas — performance d'abord, détail ensuite. |
| BMF-03 | Hiérarchie immédiate : la réponse à « combien aujourd'hui » domine ; tout le reste vient après. |
| BMF-04 | Une action principale par surface (MF-07). |
| BMF-05 | Aucune surcharge : jamais plus de six éléments d'attention (UX-07) ; les informations importantes comprises en moins de cinq secondes (UX-01). |
| BMF-06 | Ce qui touche l'argent suit UX-06 : état exact, consentement explicite, aucune action irréversible en un geste. |

---

## 9. Gouvernance

| Règle | Énoncé |
|---|---|
| BG-01 | Une information économique possède toujours une **seule source de vérité**. Aucune duplication. |
| BG-02 | Aucun calcul transversal : ce qui se calcule se calcule chez son propriétaire (mécanismes financiers, IA). |
| BG-03 | Aucune logique financière hors de son propriétaire. |
| BG-04 | La Business Platform ne possède jamais les plateformes système ; elle représente uniquement l'activité économique. |
| BG-05 | Les mécanismes financiers restent invisibles pour l'utilisateur ; la Business Platform expose uniquement une lecture métier cohérente. |
| BG-06 | Ces règles ont vocation à devenir des **règles exécutables** (balayages de gouvernance) dès la première vague d'implémentation — même discipline que le reste de l'architecture Enterprise. |

---

## 10. Extensibilité — pensé pour dix ans

| Extension | Comment elle s'insère |
|---|---|
| Plusieurs devises | la devise est un attribut des faits financiers publiés ; les domaines et les remontées ne changent pas |
| Plusieurs pays | la localisation vit chez les mécanismes financiers ; la lecture métier demeure |
| Entreprises, organisations, cabinets, équipes | un contexte d'appartenance s'ajoute à la lecture (mon activité / celle de mon équipe) ; domaines, moments et remontées restent les mêmes |
| Abonnements Premium | une source de revenus de plus dans le domaine Revenus |
| Commissions | un fait des mécanismes financiers, lu par les Revenus — jamais recalculé (BN-08) |
| Revenus Masterclass | une source de plus dans les Revenus, dont le fait générateur appartient à la Reputation Platform |
| Nouvelles sources de revenus | par construction : les Revenus ventilent par source (BS-04) |
| Nouvelles métriques économiques | de nouveaux faits publiés par leur source de vérité, représentés par le domaine compétent |

| Règle | Énoncé |
|---|---|
| BEX-01 | Les neuf domaines (§3) sont l'invariant décennal : les extensions enrichissent les domaines, elles n'en ajoutent ni n'en retirent sans révision de ce document. |
| BEX-02 | Toute extension nomme son domaine d'attache et sa source de vérité avant tout développement. |
| BEX-03 | Aucune extension ne peut réintroduire une possession interdite (BN-01 → BN-09 sont perpétuels). |
| BEX-04 | Une source de revenus dont le fait générateur appartient à une autre plateforme (Masterclass → Reputation) reste lue ici et possédée là-bas — la frontière ne se déplace jamais avec l'argent. |

---

## 11. Gouvernance du document

- Ce document est la **référence officielle** de la Business Platform. Aucun développement la concernant en dehors.
- Toute vague d'implémentation cite le domaine, le moment et les règles (BV/BP/BN/BS/BM/BPU/BMF/BG/BEX) qu'elle réalise.
- Toute modification de ce document est une décision d'architecture explicite, tracée, jamais un effet de bord d'une vague d'implémentation.
- En cas de conflit avec [MENTORA EXPERT PLATFORM V2](mentora-expert-platform-v2.md), P9.0 prévaut ; les remontées se révisent conjointement avec la [HOME PLATFORM FOUNDATION](home-platform-foundation.md) (BPU-04).
